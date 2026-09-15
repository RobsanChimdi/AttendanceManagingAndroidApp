import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/attendance_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_loading.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  final int sessionId;

  const QRScannerScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  
  bool _isCameraInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _scannedResult;
  
  // Scan cooldown
  DateTime? _lastScanTime;
  static const _scanCooldown = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    
    if (!status.isGranted) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Camera permission denied. Please enable camera access in settings.';
          _isCameraInitialized = false;
        });
      }
      return;
    }

    setState(() {
      _isCameraInitialized = true;
      _errorMessage = null;
    });
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;

    if (code == null) return;

    // Check cooldown
    if (_lastScanTime != null &&
        DateTime.now().difference(_lastScanTime!) < _scanCooldown) {
      return;
    }

    if (_isLoading) return;

    setState(() {
      _scannedResult = code;
      _lastScanTime = DateTime.now();
    });

    _processQRCode(code);
  }

  Future<void> _processQRCode(String qrToken) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _attendanceService.markQRAttendance(
        widget.sessionId,
        qrToken,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showResultDialog(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    final status = result['status'];
    
    Color backgroundColor;
    IconData icon;
    String title;
    String? subtitle;

    switch (status) {
      case 'MATCH':
        backgroundColor = AppColors.success;
        icon = Icons.check_circle;
        title = 'Attendance Marked';
        subtitle = result['student_name'];
        break;
      case 'ALREADY_PRESENT':
        backgroundColor = AppColors.warning;
        icon = Icons.info_outline;
        title = 'Already Present';
        subtitle = result['student_name'];
        break;
      case 'INVALID':
        backgroundColor = AppColors.error;
        icon = Icons.error_outline;
        title = 'Invalid QR Code';
        subtitle = result['reason'];
        break;
      default:
        backgroundColor = AppColors.textSecondary;
        icon = Icons.help_outline;
        title = 'Unknown Status';
        subtitle = null;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        icon: Icon(icon, color: Colors.white, size: 48),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(color: Colors.white),
              )
            : null,
        actions: [
          AppButton(
            text: 'OK',
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _scannedResult = null;
                _errorMessage = null;
              });
            },
            type: ButtonType.text,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('QR Attendance Scanner'),
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationSm,
      ),
      body: _errorMessage != null && !_isCameraInitialized
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

  Widget _buildScannerView() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              MobileScanner(
                onDetect: _onBarcodeDetected,
              ),
              _buildScanOverlay(),
              if (_isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: const AppLoading(message: 'Processing...'),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          color: AppColors.surface,
          child: Column(
            children: [
              if (_scannedResult != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.qr_code, color: AppColors.primary, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Scanned: ${_scannedResult!.substring(0, 8)}...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null && _scannedResult != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Point camera at student QR code',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Attendance will be marked automatically',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.7),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Positioned(top: 10, left: 10, child: _buildCornerMarker(Alignment.topLeft)),
            Positioned(top: 10, right: 10, child: _buildCornerMarker(Alignment.topRight)),
            Positioned(bottom: 10, left: 10, child: _buildCornerMarker(Alignment.bottomLeft)),
            Positioned(bottom: 10, right: 10, child: _buildCornerMarker(Alignment.bottomRight)),
            Center(
              child: Icon(
                Icons.qr_code_scanner,
                size: 80,
                color: Colors.white.withValues(alpha: 0.5),
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
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
