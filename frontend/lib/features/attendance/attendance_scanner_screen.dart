import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import '../../services/attendance_service.dart';

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
  
  // Cooldown and sampling
  Timer? _recognitionCooldown;
  static const _cooldownDuration = Duration(seconds: 3);
  static const _frameSamplingInterval = Duration(milliseconds: 500);
  DateTime? _lastRecognitionTime;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _recognitionCooldown?.cancel();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Request camera permission
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

      // Get available cameras
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

      // Initialize camera (prefer front camera for face recognition)
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

  Future<void> _captureAndRecognize() async {
    // Check cooldown
    if (_lastRecognitionTime != null &&
        DateTime.now().difference(_lastRecognitionTime!) < _cooldownDuration) {
      return;
    }

    // Check if already recognizing
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

      // Start cooldown timer
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetRecognition,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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

  Widget _buildScannerView() {
    return Column(
      children: [
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
              // Face guide overlay
              if (_isCameraInitialized)
                _buildFaceGuideOverlay(),
              // Recognition status overlay
              if (_recognitionStatus != null)
                _buildRecognitionStatusOverlay(),
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
            // Corner guides
            Positioned(
              top: 10,
              left: 10,
              child: _buildCornerMarker(TopLeft),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: _buildCornerMarker(TopRight),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: _buildCornerMarker(BottomLeft),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: _buildCornerMarker(BottomRight),
            ),
            // Center guide
            const Center(
              child: Icon(
                Icons.face,
                size: 80,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerMarker(Alignment alignment) {
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
                        // TODO: Implement QR fallback
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
