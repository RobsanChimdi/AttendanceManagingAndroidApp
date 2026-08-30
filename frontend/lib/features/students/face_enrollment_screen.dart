import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../services/student_service.dart';
import '../../models/student_models.dart';

class FaceEnrollmentScreen extends ConsumerStatefulWidget {
  final int studentId;
  final String studentName;
  final String studentIdStr;

  const FaceEnrollmentScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.studentIdStr,
  });

  @override
  ConsumerState<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends ConsumerState<FaceEnrollmentScreen> {
  final StudentService _studentService = StudentService();
  
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  int _currentSample = 1;
  final int _totalSamples = 5;
  final List<File> _capturedSamples = [];
  
  final List<String> _instructions = [
    'Look straight at the camera',
    'Turn slightly to the left',
    'Turn slightly to the right',
    'Look slightly up',
    'Look slightly down',
  ];
  
  String _detectionMessage = '';
  bool _faceDetected = false;
  bool _multipleFaces = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
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

      // Initialize camera (prefer front camera)
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

  Future<void> _captureSample() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      
      setState(() {
        _capturedSamples.add(File(image.path));
        _currentSample++;
        _faceDetected = false;
        _detectionMessage = '';
      });

      if (_currentSample > _totalSamples) {
        await _submitEnrollment();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to capture image: $e';
      });
    }
  }

  Future<void> _submitEnrollment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _studentService.enrollFace(widget.studentId, _capturedSamples);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Face enrolled successfully')),
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

  void _retakeSample() {
    setState(() {
      if (_capturedSamples.isNotEmpty) {
        _capturedSamples.removeLast();
      }
      _currentSample--;
      _faceDetected = false;
      _detectionMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Enrollment'),
        actions: [
          if (_capturedSamples.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retakeSample,
              tooltip: 'Retake last sample',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _capturedSamples.isEmpty
              ? _buildErrorView()
              : _buildEnrollmentView(),
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

  Widget _buildEnrollmentView() {
    return Column(
      children: [
        // Student info header
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.blue.shade50,
          child: Column(
            children: [
              Text(
                widget.studentName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ID: ${widget.studentIdStr}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sample $_currentSample of $_totalSamples',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...List.generate(_totalSamples, (index) {
                    final isCompleted = index < _currentSample - 1;
                    final isCurrent = index == _currentSample - 1;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? Colors.green
                            : isCurrent
                                ? Colors.blue
                                : Colors.grey.shade300,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        
        // Camera preview
        Expanded(
          child: _isCameraInitialized
              ? Stack(
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: _cameraController!.value.aspectRatio,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                    // Face guide overlay
                    _buildFaceGuideOverlay(),
                    // Detection message
                    if (_detectionMessage.isNotEmpty)
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: _faceDetected
                              ? Colors.green.withOpacity(0.8)
                              : Colors.red.withOpacity(0.8),
                          child: Text(
                            _detectionMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        ),
        
        // Instructions and controls
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_currentSample <= _totalSamples)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(height: 8),
                        Text(
                          _instructions[_currentSample - 1],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (_currentSample <= _totalSamples)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _faceDetected ? _captureSample : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _faceDetected ? Colors.green : Colors.grey,
                    ),
                    child: const Text(
                      'Capture Sample',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              if (_errorMessage != null && _capturedSamples.isNotEmpty)
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
            color: _faceDetected ? Colors.green : Colors.white,
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
        color: _faceDetected ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
