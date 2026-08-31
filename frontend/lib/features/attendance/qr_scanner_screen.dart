import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/attendance_service.dart';

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
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        title = 'Attendance Marked';
        subtitle = result['student_name'];
        break;
      case 'ALREADY_PRESENT':
        backgroundColor = Colors.orange;
        icon = Icons.info_outline;
        title = 'Already Present';
        subtitle = result['student_name'];
        break;
      case 'INVALID':
        backgroundColor = Colors.red;
        icon = Icons.error_outline;
        title = 'Invalid QR Code';
        subtitle = result['reason'];
        break;
      default:
        backgroundColor = Colors.grey;
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _scannedResult = null;
                _errorMessage = null;
              });
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Attendance Scanner'),
      ),
      body: _errorMessage != null && !_isCameraInitialized
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
        Expanded(
          child: Stack(
            children: [
              MobileScanner(
                onDetect: _onBarcodeDetected,
              ),
              _buildScanOverlay(),
              if (_isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_scannedResult != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.qr_code, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Scanned: ${_scannedResult!.substring(0, 8)}...',
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null && _scannedResult != null)
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
              const SizedBox(height: 16),
              const Text(
                'Position QR code within the frame',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
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
            color: Colors.white,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Positioned(top: 10, left: 10, child: _buildCornerMarker(TopLeft)),
            Positioned(top: 10, right: 10, child: _buildCornerMarker(TopRight)),
            Positioned(bottom: 10, left: 10, child: _buildCornerMarker(BottomLeft)),
            Positioned(bottom: 10, right: 10, child: _buildCornerMarker(BottomRight)),
            const Center(
              child: Icon(Icons.qr_code_scanner, size: 80, color: Colors.white54),
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
}
