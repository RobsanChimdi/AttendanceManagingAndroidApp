import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
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
      appBar: AppBar(
        title: const Text('Live Attendance Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetRecognition,
            tooltip: 'Reset',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showCloseConfirmation,
            tooltip: 'Close Session',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _errorMessage?.contains('permission') == true
                  ? openAppSettings
                  : _initializeCamera,
              child: Text(_errorMessage?.contains('permission') == true
                  ? 'Open Settings'
                  : 'Retry'),
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
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Expected', _sessionStats!['total_students'].toString(), Icons.people),
                    _buildStatCard('Present', _sessionStats!['present_count'].toString(), Icons.check_circle, Colors.green),
                    _buildStatCard('Absent', _sessionStats!['absent_count'].toString(), Icons.cancel, Colors.red),
                    _buildStatCard('Remaining', _sessionStats!['remaining_count'].toString(), Icons.hourglass_empty, Colors.orange),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _sessionStats!['attendance_percentage'] / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _sessionStats!['attendance_percentage'] >= 75 ? Colors.green :
                    _sessionStats!['attendance_percentage'] >= 50 ? Colors.orange : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Attendance: ${_sessionStats!['attendance_percentage'].toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner, size: 100, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'QR Scanner',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap below to open QR scanner',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/attendance/qr-scanner/${widget.sessionId}');
                  },
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Open QR Scanner'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (_recentRecognitions != null && _recentRecognitions!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16.0),
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Recognitions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _recentRecognitions!.length,
                    itemBuilder: (context, index) {
                      final record = _recentRecognitions![index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          record['status'] == 'PRESENT' ? Icons.check_circle : Icons.cancel,
                          color: record['status'] == 'PRESENT' ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        title: Text(record['student_name']),
                        subtitle: Text(record['student_id_str']),
                        trailing: Text(
                          record['recognized_at']?.toString().split('T')[1].split('.')[0] ?? '',
                          style: const TextStyle(fontSize: 12),
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
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Expected', _sessionStats!['total_students'].toString(), Icons.people),
                    _buildStatCard('Present', _sessionStats!['present_count'].toString(), Icons.check_circle, Colors.green),
                    _buildStatCard('Absent', _sessionStats!['absent_count'].toString(), Icons.cancel, Colors.red),
                    _buildStatCard('Remaining', _sessionStats!['remaining_count'].toString(), Icons.hourglass_empty, Colors.orange),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _sessionStats!['attendance_percentage'] / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _sessionStats!['attendance_percentage'] >= 75 ? Colors.green :
                    _sessionStats!['attendance_percentage'] >= 50 ? Colors.orange : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Attendance: ${_sessionStats!['attendance_percentage'].toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                    : const Center(child: CircularProgressIndicator()),
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
            padding: const EdgeInsets.all(16.0),
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Recognitions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _recentRecognitions!.length,
                    itemBuilder: (context, index) {
                      final record = _recentRecognitions![index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          record['status'] == 'PRESENT' ? Icons.check_circle : Icons.cancel,
                          color: record['status'] == 'PRESENT' ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        title: Text(record['student_name']),
                        subtitle: Text(record['student_id_str']),
                        trailing: Text(
                          record['recognized_at']?.toString().split('T')[1].split('.')[0] ?? '',
                          style: const TextStyle(fontSize: 12),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_recognitionStatus == null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isRecognizing ? null : _captureAndRecognize,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _isRecognizing ? Colors.grey : Colors.blue,
                    ),
                    child: _isRecognizing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Capture & Recognize',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              if (_errorMessage != null && _recognitionStatus == null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
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

  Widget _buildStatCard(String label, String value, IconData icon, [Color color = Colors.blue]) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
            color: Colors.white,
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
            const Center(
              child: Icon(Icons.face, size: 80, color: Colors.white54),
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
        color: Colors.white,
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
        backgroundColor = Colors.green.withOpacity(0.9);
        icon = Icons.check_circle;
        title = 'Student Recognized';
        subtitle = _alreadyMarked ? 'Already marked present' : 'Marked present';
        break;
      case 'UNKNOWN':
        backgroundColor = Colors.orange.withOpacity(0.9);
        icon = Icons.person_off;
        title = 'Unknown Person';
        subtitle = 'No matching student found';
        break;
      case 'LOW_CONFIDENCE':
        backgroundColor = Colors.amber.withOpacity(0.9);
        icon = Icons.help_outline;
        title = 'Unable to Identify';
        subtitle = 'Low confidence match';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.9);
        icon = Icons.info_outline;
        title = 'Unknown Status';
        subtitle = null;
    }

    return Positioned(
      top: 20,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 48),
            const SizedBox(height: 8),
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
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_recognitionStatus == 'MATCH' && _studentName != null) ...[
              const SizedBox(height: 12),
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
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _resetRecognition,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: backgroundColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('QR scanning coming soon')),
                        );
                      },
                      icon: const Icon(Icons.qr_code, size: 16),
                      label: const Text('Use QR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: backgroundColor,
                      ),
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
