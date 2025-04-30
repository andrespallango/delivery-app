// lib/widgets/qr_scanner_widget.dart
import 'package:flutter/material.dart';
// Actualizamos la importación a qr_code_scanner_plus
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:delivery_app/config/app_theme.dart';

class QrScannerWidget extends StatefulWidget {
  final Function(String) onScan;

  const QrScannerWidget({
    super.key,
    required this.onScan,
  });

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  bool _flashOn = false;
  bool _processingCode = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (_controller != null) {
      _controller!.pauseCamera();
      _controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      if (!_processingCode && scanData.code != null) {
        setState(() {
          _processingCode = true;
        });
        widget.onScan(scanData.code!);
      }
    });
  }

  void _toggleFlash() async {
    if (_controller != null) {
      await _controller!.toggleFlash();
      setState(() {
        _flashOn = !_flashOn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: _qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: AppTheme.primaryColor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Scan the delivery QR code',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
