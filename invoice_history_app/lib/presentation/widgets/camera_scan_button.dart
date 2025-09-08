import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_strings.dart';

class CameraScanButton extends StatefulWidget {
  final Function(String) onScanned;

  const CameraScanButton({
    super.key,
    required this.onScanned,
  });

  @override
  State<CameraScanButton> createState() => _CameraScanButtonState();
}

class _CameraScanButtonState extends State<CameraScanButton> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isScanning ? null : _scanDocument,
      icon: _isScanning
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.document_scanner),
      label: const Column(
        children: [
          Text(AppStrings.scanInvoice),
          Text(
            AppStrings.scanInvoiceArabic,
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Future<void> _scanDocument() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to scan documents'),
          ),
        );
        return;
      }

      // For now, show a placeholder message
      // In a full implementation, you would integrate with camera and OCR
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera scanning feature will be implemented with OCR integration'),
        ),
      );
      
      // Simulate scanned text for demo purposes
      await Future.delayed(const Duration(seconds: 2));
      widget.onScanned('Scanned text from document - Invoice #123, Date: ${DateTime.now().toString().split(' ')[0]}');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning document: $e')),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }
}