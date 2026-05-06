import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/constants/app_theme.dart';

/// Renders a QR code or a linear barcode depending on [format].
///
/// - `QR_CODE` → [QrImageView] from `qr_flutter`
/// - Everything else → [BarcodeWidget] from `barcode_widget` mapped to the
///   appropriate [Barcode] sub-type.
class BarcodeDisplay extends StatelessWidget {
  const BarcodeDisplay({
    super.key,
    required this.value,
    required this.format,
    this.size = 220.0,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
  });

  final String value;
  final String format;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final isQr = format.toUpperCase() == 'QR_CODE';
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(AppTheme.spaceS),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: isQr ? _buildQr() : _buildBarcode(),
    );
  }

  Widget _buildQr() {
    return QrImageView(
      data: value,
      version: QrVersions.auto,
      backgroundColor: backgroundColor,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: foregroundColor,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: foregroundColor,
      ),
    );
  }

  Widget _buildBarcode() {
    final barcodeType = _mapFormatToBarcode(format);
    if (barcodeType == null) {
      // Fallback: render as text if format is unsupported
      return Center(
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(color: foregroundColor, fontSize: 12),
        ),
      );
    }
    return bw.BarcodeWidget(
      barcode: barcodeType,
      data: value,
      color: foregroundColor,
      backgroundColor: backgroundColor,
      drawText: true,
      style: TextStyle(color: foregroundColor, fontSize: 10),
      errorBuilder: (context, error) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 32),
            const SizedBox(height: 8),
            Text(
              'Invalid barcode data',
              style: TextStyle(color: foregroundColor, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  bw.Barcode? _mapFormatToBarcode(String format) {
    switch (format.toUpperCase()) {
      case 'EAN_13':
        return bw.Barcode.ean13();
      case 'EAN_8':
        return bw.Barcode.ean8();
      case 'UPC_A':
        return bw.Barcode.upcA();
      case 'CODE_128':
        return bw.Barcode.code128();
      case 'CODE_39':
        return bw.Barcode.code39();
      case 'PDF_417':
        return bw.Barcode.pdf417();
      case 'DATA_MATRIX':
        return bw.Barcode.dataMatrix();
      case 'AZTEC':
        return bw.Barcode.aztec();
      case 'ITF':
        return bw.Barcode.itf();
      case 'CODABAR':
        return bw.Barcode.codabar();
      default:
        return bw.Barcode.code128();
    }
  }
}
