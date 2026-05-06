import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_theme.dart';
import '../core/utils/screen_utils.dart';
import '../models/barcode_item.dart';
import '../providers/barcode_provider.dart';

/// Full-screen barcode scanner using [MobileScanner].
///
/// Flow:
/// 1. Camera preview fills the screen.
/// 2. On first valid scan: show an add-label dialog.
/// 3. If the barcode already exists: inform the user.
/// 4. Manual entry available via the keyboard icon.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    returnImage: false,
  );

  bool _isProcessing = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Scan handling ─────────────────────────────────────────────────────────────

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    _isProcessing = true;
    _controller.stop();

    final value = barcode.rawValue!;
    final format = barcode.format.name.toUpperCase();

    if (!mounted) return;
    await _showAddDialog(value, format);
  }

  Future<void> _showAddDialog(String value, String format) async {
    final provider = context.read<BarcodeProvider>();
    final labelCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AddBarcodeDialog(
        value: value,
        format: format,
        labelCtrl: labelCtrl,
      ),
    );

    if (result == true) {
      final item = BarcodeItem(
        value: value,
        format: format,
        label: labelCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      final added = await provider.addBarcode(item);
      if (mounted) {
        if (added) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${ScreenUtils.formatLabel(format)} saved'
                    '${item.label.isNotEmpty ? ': ${item.label}' : ''}',
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This barcode is already saved.'),
              backgroundColor: AppTheme.error,
            ),
          );
          _resumeScanning();
        }
      }
    } else {
      _resumeScanning();
    }
    labelCtrl.dispose();
  }

  void _resumeScanning() {
    _isProcessing = false;
    _controller.start();
  }

  void _toggleTorch() {
    _controller.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  void _openManualEntry(BuildContext context) async {
    _controller.stop();
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      builder: (_) => const _ManualEntrySheet(),
    );

    if (result != null && mounted) {
      await _showAddDialog(result['value']!, result['format']!);
    } else {
      _resumeScanning();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _torchOn ? Colors.amber : AppTheme.onSurface,
            ),
            tooltip: 'Toggle flash',
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_rounded),
            tooltip: 'Manual entry',
            onPressed: () => _openManualEntry(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Scan overlay
          const _ScanOverlay(),
        ],
      ),
    );
  }
}

// ── Scan overlay ──────────────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    const boxSize = 260.0;
    return Stack(
      children: [
        // Dim areas outside the box
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                child: Container(
                  width: boxSize,
                  height: boxSize,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Corner brackets
        const Center(
          child: SizedBox(
            width: boxSize,
            height: boxSize,
            child: _CornerBrackets(),
          ),
        ),
        // Helper text
        Positioned(
          bottom: size.height * 0.18,
          left: 0,
          right: 0,
          child: const Text(
            'Point camera at a QR code or barcode',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _CornerBrackets extends StatelessWidget {
  const _CornerBrackets();

  @override
  Widget build(BuildContext context) {
    const len = 28.0;
    const thick = 3.0;
    const color = AppTheme.primary;
    const r = Radius.circular(4);

    return const CustomPaint(
      painter: _BracketPainter(
        length: len,
        thickness: thick,
        color: color,
        radius: r,
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  const _BracketPainter({
    required this.length,
    required this.thickness,
    required this.color,
    required this.radius,
  });

  final double length;
  final double thickness;
  final Color color;
  final Radius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Top-left
    _drawCorner(canvas, paint, 0, 0, 1, 1);
    // Top-right
    _drawCorner(canvas, paint, w, 0, -1, 1);
    // Bottom-left
    _drawCorner(canvas, paint, 0, h, 1, -1);
    // Bottom-right
    _drawCorner(canvas, paint, w, h, -1, -1);
  }

  void _drawCorner(
      Canvas canvas, Paint paint, double x, double y, double dx, double dy) {
    final path = Path()
      ..moveTo(x + dx * length, y)
      ..lineTo(x, y)
      ..lineTo(x, y + dy * length);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Add barcode dialog ────────────────────────────────────────────────────────

class _AddBarcodeDialog extends StatelessWidget {
  const _AddBarcodeDialog({
    required this.value,
    required this.format,
    required this.labelCtrl,
  });

  final String value;
  final String format;
  final TextEditingController labelCtrl;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceVariant,
      title: Row(
        children: [
          Icon(ScreenUtils.formatIcon(format),
              color: AppTheme.primary, size: 22),
          const SizedBox(width: 8),
          Text(ScreenUtils.formatLabel(format)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scanned value:',
            style: AppTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value.length > 60 ? '${value.substring(0, 57)}…' : value,
            style: AppTheme.bodyLarge,
          ),
          const SizedBox(height: AppTheme.spaceM),
          TextField(
            controller: labelCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Add a label (optional)',
              prefixIcon: Icon(Icons.label_outline_rounded,
                  color: AppTheme.primary, size: 18),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ── Manual entry bottom sheet ─────────────────────────────────────────────────

class _ManualEntrySheet extends StatefulWidget {
  const _ManualEntrySheet();

  @override
  State<_ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<_ManualEntrySheet> {
  final _valueCtrl = TextEditingController();
  String _selectedFormat = 'QR_CODE';

  static const _formats = [
    ('QR_CODE', 'QR Code'),
    ('EAN_13', 'EAN-13'),
    ('EAN_8', 'EAN-8'),
    ('UPC_A', 'UPC-A'),
    ('CODE_128', 'Code 128'),
    ('CODE_39', 'Code 39'),
    ('PDF_417', 'PDF-417'),
    ('DATA_MATRIX', 'DataMatrix'),
  ];

  @override
  void dispose() {
    _valueCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final v = _valueCtrl.text.trim();
    if (v.isEmpty) return;
    Navigator.pop(context, {'value': v, 'format': _selectedFormat});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppTheme.spaceM),
                decoration: BoxDecoration(
                  color: AppTheme.onSurfaceMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text('Manual Entry', style: AppTheme.titleLarge),
            const SizedBox(height: AppTheme.spaceM),

            // Format selector
            DropdownButtonFormField<String>(
              initialValue: _selectedFormat,
              dropdownColor: AppTheme.surfaceVariant,
              decoration: const InputDecoration(
                labelText: 'Format',
                labelStyle: TextStyle(color: AppTheme.onSurfaceMuted),
              ),
              items: _formats.map((f) {
                return DropdownMenuItem(
                  value: f.$1,
                  child: Text(f.$2, style: AppTheme.bodyLarge),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedFormat = v!),
            ),
            const SizedBox(height: AppTheme.spaceM),

            // Value input
            TextField(
              controller: _valueCtrl,
              autofocus: true,
              style: AppTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Enter barcode value…',
                labelText: 'Value',
                labelStyle: TextStyle(color: AppTheme.onSurfaceMuted),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppTheme.spaceL),

            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Add barcode'),
            ),
            const SizedBox(height: AppTheme.spaceS),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
