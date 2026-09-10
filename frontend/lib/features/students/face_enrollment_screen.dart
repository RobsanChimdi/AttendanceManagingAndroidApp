import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_loading.dart';
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
          _faceDetected = true;
          _detectionMessage = 'Face detection ready';
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
        _faceDetected = true;
        _detectionMessage = 'Sample ${_capturedSamples.length} captured';
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
      _faceDetected = true;
      _detectionMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Face Enrollment'),
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationSm,
        actions: [
          if (_capturedSamples.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retakeSample,
              tooltip: 'Retake last sample',
              color: AppColors.textSecondary,
            ),
        ],
      ),
      body: _isLoading
          ? const AppLoading(message: 'Initializing camera...')
          : _errorMessage != null && _capturedSamples.isEmpty
              ? _buildErrorView()
              : _buildEnrollmentView(),
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

  Widget _buildEnrollmentView() {
    return Column(
      children: [
        // Student info header
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          color: AppColors.primary.withOpacity(0.05),
          child: Column(
            children: [
              Text(
                widget.studentName,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'ID: ${widget.studentIdStr}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enrollment $_currentSample / $_totalSamples',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ...List.generate(_totalSamples, (index) {
                    final isCompleted = index < _currentSample - 1;
                    final isCurrent = index == _currentSample - 1;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.success
                            : isCurrent
                                ? AppColors.primary
                                : AppColors.border,
                      ),
                    );
                  }),
                ],
              ),
              
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${((_currentSample - 1) / _totalSamples * 100).toInt()}% Complete',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
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
                        top: AppSpacing.lg,
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: _faceDetected
                                ? AppColors.success.withOpacity(0.9)
                                : AppColors.error.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _faceDetected ? Icons.check_circle : Icons.error_outline,
                                color: Colors.white,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                _detectionMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
              : const AppLoading(message: 'Initializing camera...'),
        ),
        
        // Instructions and controls
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          color: AppColors.surface,
          child: Column(
            children: [
              if (_currentSample <= _totalSamples)
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  backgroundColor: AppColors.info.withOpacity(0.1),
                  isBordered: true,
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          _instructions[_currentSample - 1],
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              if (_currentSample <= _totalSamples)
                AppButton(
                  text: 'Capture Sample',
                  onPressed: _faceDetected ? _captureSample : null,
                  isFullWidth: true,
                  type: _faceDetected ? ButtonType.primary : ButtonType.secondary,
                  icon: Icons.camera_alt,
                ),
              if (_errorMessage != null && _capturedSamples.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
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

  Widget _buildFaceGuideOverlay() {
    return Center(
      child: Container(
        width: 280,
        height: 350,
        decoration: BoxDecoration(
          border: Border.all(
            color: _faceDetected ? AppColors.success : Colors.white.withOpacity(0.7),
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
              child: _buildCornerMarker(),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: _buildCornerMarker(),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: _buildCornerMarker(),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: _buildCornerMarker(),
            ),
            // Center guide
            Center(
              child: Icon(
                Icons.face,
                size: 80,
                color: _faceDetected ? AppColors.success : Colors.white.withOpacity(0.5),
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
        color: _faceDetected ? AppColors.success : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
