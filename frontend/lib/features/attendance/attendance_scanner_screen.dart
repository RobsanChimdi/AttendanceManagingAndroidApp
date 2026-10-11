import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_loading.dart';
import '../../services/attendance_service.dart';
import '../../services/attendance_session_service.dart';

class AttendanceScannerScreen extends ConsumerStatefulWidget {
  final int sessionId;

  const AttendanceScannerScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<AttendanceScannerScreen> createState() => _AttendanceScannerScreenState();
}

class _AttendanceScannerScreenState extends ConsumerState<AttendanceScannerScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final AttendanceSessionService _sessionService = AttendanceSessionService();
  
  // Scan mode: 'face' or 'qr'
  String _scanMode = 'face';
  
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Recognition state
  bool _isRecognizing = false;
  String? _recognitionStatus; // MATCH, UNKNOWN, LOW_CONFIDENCE
  String? _studentName;
  String? _studentIdStr;
  double? _confidence;
  bool _alreadyMarked = false;
  
  // Session statistics
  Map<String, dynamic>? _sessionStats;
  List<dynamic>? _recentRecognitions;
  
  // Cooldown and sampling
  Timer? _recognitionCooldown;
  Timer? _statsRefreshTimer;
  static const _cooldownDuration = Duration(seconds: 3);
  static const _statsRefreshInterval = Duration(seconds: 5);
  DateTime? _lastRecognitionTime;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadSessionStatistics();
    _startStatsRefreshTimer();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _recognitionCooldown?.cancel();
    _statsRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final status = await Permission.camera.request();
      
      if (!status.isGranted) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Camera permission denied. Please enable camera access in settings.';
            _isLoading = false;
          });
        }
        return;
      }

      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'No camera available on this device.';
            _isLoading = false;
          });
        }
        return;
      }

      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize camera: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _startStatsRefreshTimer() {
    _statsRefreshTimer = Timer.periodic(_statsRefreshInterval, (_) {
      _loadSessionStatistics();
    });
  }

  Future<void> _loadSessionStatistics() async {
    try {
      final stats = await _sessionService.getSessionStatistics(widget.sessionId);
      final attendance = await _sessionService.getSessionAttendance(widget.sessionId);
      
      if (mounted) {
        setState(() {
          _sessionStats = stats;
          _recentRecognitions = attendance.take(5).toList();
        });
      }
    } catch (e) {
      // Don't show error for stats refresh failures
    }
  }

  Future<void> _captureAndRecognize() async {
    if (_lastRecognitionTime != null &&
        DateTime.now().difference(_lastRecognitionTime!) < _cooldownDuration) {
      return;
    }

    if (_isRecognizing) {
      return;
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isRecognizing = true;
      _recognitionStatus = null;
      _errorMessage = null;
    });

    try {
      final image = await _cameraController!.takePicture();
      
      final result = await _attendanceService.recognizeFace(
        widget.sessionId,
        File(image.path),
      );

      setState(() {
        _recognitionStatus = result['status'];
        _studentName = result['student_name'];
        _studentIdStr = result['student_id_str'];
        _confidence = result['confidence'];
        _alreadyMarked = result['already_marked'] ?? false;
        _lastRecognitionTime = DateTime.now();
      });

      // Refresh stats after recognition
      _loadSessionStatistics();

      _recognitionCooldown?.cancel();
      _recognitionCooldown = Timer(_cooldownDuration, () {
        if (mounted) {
          setState(() {
            _recognitionStatus = null;
            _studentName = null;
            _studentIdStr = null;
            _confidence = null;
            _alreadyMarked = false;
          });
        }
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRecognizing = false;
        });
      }
    }
  }

  void _resetRecognition() {
    setState(() {
      _recognitionStatus = null;
      _studentName = null;
      _studentIdStr = null;
      _confidence = null;
      _alreadyMarked = false;
      _errorMessage = null;
    });
  }

  void _showCloseConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Attendance Session'),
        content: const Text(
          'Students who have not been marked present will be marked absent. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _closeSession();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Close Session'),
          ),
        ],
      ),
    );
  }

  Future<void> _closeSession() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _sessionService.closeSession(widget.sessionId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance session closed successfully')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Attendance Scanner'),
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationSm,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetRecognition,
            tooltip: 'Reset',
            color: AppColors.textSecondary,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showCloseConfirmation,
            tooltip: 'Close Session',
            color: AppColors.error,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'face',
                        label: Text('Face'),
                        icon: Icon(Icons.face),
                      ),
                      ButtonSegment(
                        value: 'qr',
                        label: Text('QR'),
                        icon: Icon(Icons.qr_code),
                      ),
                    ],
                    selected: {_scanMode},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _scanMode = newSelection.first;
                        _resetRecognition();
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.primary.withValues(alpha: 0.1);
                        }
                        return AppColors.surfaceVariant;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.primary;
                        }
                        return AppColors.textSecondary;
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const AppLoading(message: 'Initializing camera...')
          : _scanMode == 'qr'
              ? _buildQRScannerPlaceholder()
              : _errorMessage != null && _recognitionStatus == null
                  ? _buildErrorView()
                  : _buildScannerView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              text: _errorMessage?.contains('permission') == true
                  ? 'Open Settings'
                  : 'Retry',
              onPressed: _errorMessage?.contains('permission') == true
                  ? openAppSettings
                  : _initializeCamera,
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRScannerPlaceholder() {
    return Column(
      children: [
        if (_sessionStats != null)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            backgroundColor: AppColors.primary.withValues(alpha: 0.05),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Expected', _sessionStats!['total_students'].toString(), Icons.people, AppColors.primary),
                    _buildStatCard('Present', _sessionStats!['present_count'].toString(), Icons.check_circle, AppColors.success),
                    _buildStatCard('Absent', _sessionStats!['absent_count'].toString(), Icons.cancel, AppColors.error),
                    _buildStatCard('Remaining', _sessionStats!['remaining_count'].toString(), Icons.hourglass_empty, AppColors.warning),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                LinearProgressIndicator(
                  value: _sessionStats!['attendance_percentage'] / 100,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _sessionStats!['attendance_percentage'] >= 75 ? AppColors.success :
                    _sessionStats!['attendance_percentage'] >= 50 ? AppColors.warning : AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Attendance: ${_sessionStats!['attendance_percentage'].toStringAsFixed(1)}%',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, size: 100, color: AppColors.textHint),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'QR Scanner',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tap below to open QR scanner',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: 'Open QR Scanner',
                  icon: Icons.qr_code,
                  onPressed: () {
                    context.push('/attendance/qr-scanner/${widget.sessionId}');
                  },
                  type: ButtonType.primary,
                ),
              ],
            ),
          ),
        ),
        
        if (_recentRecognitions != null && _recentRecognitions!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            height: 180,
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Recognitions',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: ListView.builder(
                    itemCount: _recentRecognitions!.length,
                    itemBuilder: (context, index) {
                      final record = _recentRecognitions![index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          record['status'] == 'PRESENT' ? Icons.check_circle : Icons.cancel,
                          color: record['status'] == 'PRESENT' ? AppColors.success : AppColors.error,
                          size: 20,
                        ),
                        title: Text(
                          record['student_name'],
                          style: AppTextStyles.bodyMedium,
                        ),
                        subtitle: Text(
                          record['student_id_str'],
                          style: AppTextStyles.bodySmall,
                        ),
                        trailing: Text(
                          record['recognized_at']?.toString().split('T')[1].split('.')[0] ?? '',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildScannerView() {
    return Column(
      children: [
        // Statistics header
        if (_sessionStats != null)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            backgroundColor: AppColors.primary.withValues(alpha: 0.05),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Expected', _sessionStats!['total_students'].toString(), Icons.people, AppColors.primary),
                    _buildStatCard('Present', _sessionStats!['present_count'].toString(), Icons.check_circle, AppColors.success),
                    _buildStatCard('Absent', _sessionStats!['absent_count'].toString(), Icons.cancel, AppColors.error),
                    _buildStatCard('Remaining', _sessionStats!['remaining_count'].toString(), Icons.hourglass_empty, AppColors.warning),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                LinearProgressIndicator(
                  value: _sessionStats!['attendance_percentage'] / 100,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _sessionStats!['attendance_percentage'] >= 75 ? AppColors.success :
                    _sessionStats!['attendance_percentage'] >= 50 ? AppColors.warning : AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Attendance: ${_sessionStats!['attendance_percentage'].toStringAsFixed(1)}%',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        
        // Camera preview
        Expanded(
          child: Stack(
            children: [
              Center(
                child: _isCameraInitialized
                    ? AspectRatio(
                        aspectRatio: _cameraController!.value.aspectRatio,
                        child: CameraPreview(_cameraController!),
                      )
                    : const AppLoading(message: 'Initializing camera...'),
              ),
              if (_isCameraInitialized)
                _buildFaceGuideOverlay(),
              if (_recognitionStatus != null)
                _buildRecognitionStatusOverlay(),
            ],
          ),
        ),
        
        // Recent recognitions
        if (_recentRecognitions != null && _recentRecognitions!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            height: 180,
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Recognitions',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: ListView.builder(
                    itemCount: _recentRecognitions!.length,
                    itemBuilder: (context, index) {
                      final record = _recentRecognitions![index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          record['status'] == 'PRESENT' ? Icons.check_circle : Icons.cancel,
                          color: record['status'] == 'PRESENT' ? AppColors.success : AppColors.error,
                          size: 20,
                        ),
                        title: Text(
                          record['student_name'],
                          style: AppTextStyles.bodyMedium,
                        ),
                        subtitle: Text(
                          record['student_id_str'],
                          style: AppTextStyles.bodySmall,
                        ),
                        trailing: Text(
                          record['recognized_at']?.toString().split('T')[1].split('.')[0] ?? '',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        
        // Controls
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          color: AppColors.surface,
          child: Column(
            children: [
              if (_recognitionStatus == null)
                AppButton(
                  text: 'Capture & Recognize',
                  icon: Icons.camera_alt,
                  onPressed: _isRecognizing ? null : _captureAndRecognize,
                  isFullWidth: true,
                  isLoading: _isRecognizing,
                  type: _isRecognizing ? ButtonType.secondary : ButtonType.primary,
                ),
              if (_errorMessage != null && _recognitionStatus == null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppColors.error, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFaceGuideOverlay() {
    return Center(
      child: Container(
        width: 280,
        height: 350,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.7),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(140),
        ),
        child: Stack(
          children: [
            Positioned(top: 10, left: 10, child: _buildCornerMarker()),
            Positioned(top: 10, right: 10, child: _buildCornerMarker()),
            Positioned(bottom: 10, left: 10, child: _buildCornerMarker()),
            Positioned(bottom: 10, right: 10, child: _buildCornerMarker()),
            Center(
              child: Icon(
                Icons.face,
                size: 80,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerMarker() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildRecognitionStatusOverlay() {
    Color backgroundColor;
    IconData icon;
    String title;
    String? subtitle;

    switch (_recognitionStatus) {
      case 'MATCH':
        backgroundColor = AppColors.success.withValues(alpha: 0.95);
        icon = Icons.check_circle;
        title = '✓ STUDENT RECOGNIZED';
        subtitle = _alreadyMarked ? 'Already marked present' : 'Marked present';
        break;
      case 'UNKNOWN':
        backgroundColor = AppColors.warning.withValues(alpha: 0.95);
        icon = Icons.person_off;
        title = '? UNKNOWN PERSON';
        subtitle = 'No matching student found';
        break;
      case 'LOW_CONFIDENCE':
        backgroundColor = AppColors.warning.withValues(alpha: 0.95);
        icon = Icons.help_outline;
        title = '! LOW CONFIDENCE';
        subtitle = 'Low confidence match';
        break;
      default:
        backgroundColor = AppColors.textSecondary.withValues(alpha: 0.95);
        icon = Icons.info_outline;
        title = 'Unknown Status';
        subtitle = null;
    }

    return Positioned(
      top: AppSpacing.lg,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 48),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_recognitionStatus == 'MATCH' && _studentName != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _studentName!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_studentIdStr != null)
                Text(
                  'ID: $_studentIdStr',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              if (_confidence != null)
                Text(
                  'Confidence: ${(_confidence! * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
            ],
            if (_recognitionStatus == 'UNKNOWN' || _recognitionStatus == 'LOW_CONFIDENCE')
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppButton(
                      text: 'Try Again',
                      icon: Icons.refresh,
                      onPressed: _resetRecognition,
                      type: ButtonType.outline,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppButton(
                      text: 'Use QR',
                      icon: Icons.qr_code,
                      onPressed: () {
                        setState(() {
                          _scanMode = 'qr';
                        });
                      },
                      type: ButtonType.outline,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
