import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/constants/app_theme.dart';

/// Renders a QR code or a linear barcode depending on [format].
///
/// Optimisations applied for the Z Flip 6 cover screen:
/// 1. **QR codes** are pre-rendered to a [ui.Image] asynchronously via
///    [QrPainter.toImage] so the main thread is never blocked by matrix
///    computation.  The result is cached in a static map keyed by
///    `"value:format:size"` so tapping the same barcode a second time is
///    instant.
/// 2. **Linear barcodes** are wrapped in a [RepaintBoundary] so that parent
///    rebuilds never trigger a repaint of the expensive custom painter.
/// 3. A lightweight shimmer placeholder is shown while the QR is rendering
///    so the UI feels responsive from the first frame.
class BarcodeDisplay extends StatefulWidget {
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

  /// Process-wide cache: reused across hot reloads and widget tree re-mounts.
  static final Map<String, ui.Image> _qrImageCache = {};

  @override
  State<BarcodeDisplay> createState() => _BarcodeDisplayState();
}

class _BarcodeDisplayState extends State<BarcodeDisplay> {
  ui.Image? _qrImage;
  bool _loading = false;

  // Pre-resolved barcode type so _mapFormatToBarcode is only called once.
  late final bw.Barcode? _barcodeType;
  late final bool _isQr;

  @override
  void initState() {
    super.initState();
    _isQr = widget.format.toUpperCase() == 'QR_CODE';
    _barcodeType = _isQr ? null : _mapFormatToBarcode(widget.format);
    if (_isQr) _resolveQrImage();
  }

  @override
  void didUpdateWidget(BarcodeDisplay old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value ||
        old.format != widget.format ||
        old.size != widget.size) {
      if (_isQr) _resolveQrImage();
    }
  }

  String get _cacheKey =>
      '${widget.value}:${widget.format}:${widget.size.toInt()}';

  Future<void> _resolveQrImage() async {
    final key = _cacheKey;

    // 1. Cache hit — no work needed.
    if (BarcodeDisplay._qrImageCache.containsKey(key)) {
      if (mounted) setState(() => _qrImage = BarcodeDisplay._qrImageCache[key]);
      return;
    }

    if (mounted) setState(() => _loading = true);

    // 2. Render asynchronously — QrPainter.toImage() is awaitable and
    //    does not block the raster thread.
    try {
      final painter = QrPainter(
        data: widget.value,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: widget.foregroundColor,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: widget.foregroundColor,
        ),
      );
      final rendered = await painter.toImage(widget.size);
      BarcodeDisplay._qrImageCache[key] = rendered;
      if (mounted) setState(() { _qrImage = rendered; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      padding: const EdgeInsets.all(AppTheme.spaceS),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: _isQr ? _buildQr() : _buildLinear(),
    );
  }

  // ── QR ────────────────────────────────────────────────────────────────────

  Widget _buildQr() {
    if (_loading || _qrImage == null) {
      return _QrPlaceholder(color: widget.foregroundColor.withValues(alpha: 0.15));
    }
    // RawImage is the cheapest way to display an already-rasterised ui.Image.
    return RawImage(image: _qrImage, fit: BoxFit.contain);
  }

  // ── Linear barcode ────────────────────────────────────────────────────────

  Widget _buildLinear() {
    if (_barcodeType == null) {
      return Center(
        child: Text(
          widget.value,
          textAlign: TextAlign.center,
          style: TextStyle(color: widget.foregroundColor, fontSize: 12),
        ),
      );
    }
    // RepaintBoundary isolates the custom painter so parent rebuilds
    // (e.g. theme changes, safe-area recalcs) never re-invoke it.
    return RepaintBoundary(
      child: bw.BarcodeWidget(
        barcode: _barcodeType,
        data: widget.value,
        color: widget.foregroundColor,
        backgroundColor: widget.backgroundColor,
        drawText: true,
        style: TextStyle(color: widget.foregroundColor, fontSize: 10),
        errorBuilder: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 32),
              const SizedBox(height: 8),
              Text(
                'Invalid barcode data',
                style: TextStyle(color: widget.foregroundColor, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Format mapping (called once in initState) ─────────────────────────────

  static bw.Barcode? _mapFormatToBarcode(String format) {
    switch (format.toUpperCase()) {
      case 'EAN_13':      return bw.Barcode.ean13();
      case 'EAN_8':       return bw.Barcode.ean8();
      case 'UPC_A':       return bw.Barcode.upcA();
      case 'CODE_128':    return bw.Barcode.code128();
      case 'CODE_39':     return bw.Barcode.code39();
      case 'PDF_417':     return bw.Barcode.pdf417();
      case 'DATA_MATRIX': return bw.Barcode.dataMatrix();
      case 'AZTEC':       return bw.Barcode.aztec();
      case 'ITF':         return bw.Barcode.itf();
      case 'CODABAR':     return bw.Barcode.codabar();
      default:            return bw.Barcode.code128();
    }
  }
}

// ── Shimmer placeholder shown while QR is rendering ─────────────────────────

class _QrPlaceholder extends StatefulWidget {
  const _QrPlaceholder({required this.color});
  final Color color;

  @override
  State<_QrPlaceholder> createState() => _QrPlaceholderState();
}

class _QrPlaceholderState extends State<_QrPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 0.8).animate(_ctrl),
      child: Container(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
