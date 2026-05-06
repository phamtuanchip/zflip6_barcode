import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Utilities for detecting the Samsung Z Flip 6 cover screen.
///
/// The Z Flip 6 cover screen is ~260 × 512 dp in portrait, so we check
/// both axes.  A 280 dp width threshold and a 560 dp height threshold give
/// comfortable headroom without mis-classifying normal phones in split-screen.
class ScreenUtils {
  ScreenUtils._();

  static const double _coverMaxWidthDp = 280.0;
  static const double _coverMaxHeightDp = 560.0;

  /// Returns `true` when the widget tree believes it is running on the Z Flip 6
  /// cover screen.  Call this **after** the first frame (e.g. inside [build]).
  static bool isCoverScreen(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width < _coverMaxWidthDp && size.height < _coverMaxHeightDp;
  }

  /// Returns `true` based solely on the platform [ui.FlutterView] physical size,
  /// which is available before the widget tree exists.  Useful in [main.dart].
  static bool isCoverScreenFromView() {
    final view = ui.PlatformDispatcher.instance.views.firstOrNull;
    if (view == null) return false;
    final dpr = view.devicePixelRatio;
    final physicalSize = view.physicalSize;
    final widthDp = physicalSize.width / dpr;
    final heightDp = physicalSize.height / dpr;
    return widthDp < _coverMaxWidthDp && heightDp < _coverMaxHeightDp;
  }

  /// Returns a human-readable label for the barcode format string.
  static String formatLabel(String format) {
    switch (format.toUpperCase()) {
      case 'QR_CODE':
        return 'QR Code';
      case 'EAN_13':
        return 'EAN-13';
      case 'EAN_8':
        return 'EAN-8';
      case 'UPC_A':
        return 'UPC-A';
      case 'CODE_128':
        return 'Code 128';
      case 'CODE_39':
        return 'Code 39';
      case 'PDF_417':
        return 'PDF-417';
      case 'DATA_MATRIX':
        return 'DataMatrix';
      case 'AZTEC':
        return 'Aztec';
      default:
        return format;
    }
  }

  /// Returns a material icon appropriate for the barcode format.
  static IconData formatIcon(String format) {
    switch (format.toUpperCase()) {
      case 'QR_CODE':
        return Icons.qr_code_2_rounded;
      default:
        return Icons.barcode_reader;
    }
  }
}
