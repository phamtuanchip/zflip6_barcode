import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/app_theme.dart';
import '../core/utils/screen_utils.dart';
import '../models/barcode_item.dart';
import '../providers/barcode_provider.dart';
import '../widgets/barcode_display.dart';

/// Shows the full detail of a stored [BarcodeItem].
///
/// Features:
/// - Visual barcode render (QR or linear)
/// - Tap to enlarge in a dialog
/// - Editable label (inline)
/// - Copy / Share / Delete actions
class BarcodeDetailScreen extends StatefulWidget {
  const BarcodeDetailScreen({super.key, required this.item});

  final BarcodeItem item;

  @override
  State<BarcodeDetailScreen> createState() => _BarcodeDetailScreenState();
}

class _BarcodeDetailScreenState extends State<BarcodeDetailScreen> {
  late final TextEditingController _labelCtrl;
  bool _editingLabel = false;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.item.label);
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _saveLabel(BarcodeProvider provider) async {
    final newLabel = _labelCtrl.text.trim();
    if (widget.item.id != null) {
      await provider.updateLabel(widget.item.id!, newLabel);
      widget.item.label = newLabel;
    }
    setState(() => _editingLabel = false);
  }

  void _copyValue(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.item.value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Value copied to clipboard')),
    );
  }

  Future<void> _shareValue() async {
    await Share.share(widget.item.value, subject: widget.item.displayName);
  }

  Future<void> _deleteBarcode(BuildContext context, BarcodeProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        title: const Text('Delete barcode?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && widget.item.id != null) {
      await provider.deleteBarcode(widget.item.id!);
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _showEnlarged(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spaceM),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: BarcodeDisplay(
              value: widget.item.value,
              format: widget.item.format,
              size: MediaQuery.sizeOf(context).width * 0.8,
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BarcodeProvider>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Barcode Detail'),
        actions: [
          IconButton(
            tooltip: 'Copy value',
            icon: const Icon(Icons.copy_rounded),
            onPressed: () => _copyValue(context),
          ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareValue,
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
            onPressed: () => _deleteBarcode(context, provider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Barcode image ─────────────────────────────────────────────────
            _BarcodeCard(
              value: widget.item.value,
              format: widget.item.format,
              onTap: () => _showEnlarged(context),
            ),

            const SizedBox(height: AppTheme.spaceL),

            // ── Info card ─────────────────────────────────────────────────────
            _InfoCard(
              item: widget.item,
              editingLabel: _editingLabel,
              labelCtrl: _labelCtrl,
              onEditTap: () => setState(() => _editingLabel = true),
              onSave: () => _saveLabel(provider),
              onCancelEdit: () {
                _labelCtrl.text = widget.item.label;
                setState(() => _editingLabel = false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _BarcodeCard extends StatelessWidget {
  const _BarcodeCard({
    required this.value,
    required this.format,
    required this.onTap,
  });

  final String value;
  final String format;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceL),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: AppTheme.dividerColor, width: 0.5),
        ),
        child: Column(
          children: [
            BarcodeDisplay(
              value: value,
              format: format,
              size: MediaQuery.sizeOf(context).width - AppTheme.spaceXL * 3,
            ),
            const SizedBox(height: AppTheme.spaceS),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.zoom_in_rounded, size: 16, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text(
                  'Tap to enlarge',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.item,
    required this.editingLabel,
    required this.labelCtrl,
    required this.onEditTap,
    required this.onSave,
    required this.onCancelEdit,
  });

  final BarcodeItem item;
  final bool editingLabel;
  final TextEditingController labelCtrl;
  final VoidCallback onEditTap;
  final VoidCallback onSave;
  final VoidCallback onCancelEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceM),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label row ───────────────────────────────────────────────────────
          Row(
            children: [
              const Text('Label', style: AppTheme.bodySmall),
              const Spacer(),
              if (!editingLabel)
                GestureDetector(
                  onTap: onEditTap,
                  child: Row(
                    children: [
                      const Icon(Icons.edit_rounded,
                          size: 14, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text('Edit',
                          style: AppTheme.bodySmall
                              .copyWith(color: AppTheme.primary)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXS),
          if (editingLabel)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: labelCtrl,
                    autofocus: true,
                    style: AppTheme.titleMedium,
                    decoration: const InputDecoration(
                      hintText: 'Enter label…',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check_rounded, color: AppTheme.primary),
                  onPressed: onSave,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppTheme.onSurfaceMuted),
                  onPressed: onCancelEdit,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            )
          else
            Text(
              item.label.trim().isNotEmpty ? item.label : '(no label)',
              style: AppTheme.titleMedium.copyWith(
                color: item.label.trim().isNotEmpty
                    ? AppTheme.onBackground
                    : AppTheme.onSurfaceMuted,
              ),
            ),

          const SizedBox(height: AppTheme.spaceM),
          const Divider(height: 1, color: AppTheme.dividerColor),
          const SizedBox(height: AppTheme.spaceM),

          // ── Format ──────────────────────────────────────────────────────────
          _Row(
            label: 'Format',
            child: _FormatBadge(format: item.format),
          ),
          const SizedBox(height: AppTheme.spaceM),

          // ── Value ────────────────────────────────────────────────────────────
          const Text('Value', style: AppTheme.bodySmall),
          const SizedBox(height: AppTheme.spaceXS),
          SelectableText(item.value, style: AppTheme.bodyLarge),

          const SizedBox(height: AppTheme.spaceM),
          const Divider(height: 1, color: AppTheme.dividerColor),
          const SizedBox(height: AppTheme.spaceM),

          // ── Date ─────────────────────────────────────────────────────────────
          _Row(
            label: 'Saved',
            child: Text(
              _formatDate(item.createdAt),
              style: AppTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}'
        '  ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: AppTheme.bodySmall),
        const SizedBox(width: AppTheme.spaceM),
        child,
      ],
    );
  }
}

class _FormatBadge extends StatelessWidget {
  const _FormatBadge({required this.format});
  final String format;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ScreenUtils.formatIcon(format),
              size: 14, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(
            ScreenUtils.formatLabel(format),
            style: AppTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
