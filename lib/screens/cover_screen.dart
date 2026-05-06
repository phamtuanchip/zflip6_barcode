import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_theme.dart';
import '../core/utils/screen_utils.dart';
import '../models/barcode_item.dart';
import '../providers/barcode_provider.dart';
import '../widgets/cover_barcode_detail.dart';

/// Optimised UI for the Samsung Z Flip 6 cover screen (~260 × 512 dp).
///
/// Layout:
/// - AMOLED black background (saves battery on OLED panel)
/// - Compact header with app name
/// - Scrollable list of saved barcodes (label + format icon)
/// - Tap a barcode → full-screen [CoverBarcodeDetail] shown in place
class CoverScreen extends StatefulWidget {
  const CoverScreen({super.key});

  @override
  State<CoverScreen> createState() => _CoverScreenState();
}

class _CoverScreenState extends State<CoverScreen> {
  BarcodeItem? _selected;

  @override
  Widget build(BuildContext context) {
    if (_selected != null) {
      return CoverBarcodeDetail(
        item: _selected!,
        onBack: () => setState(() => _selected = null),
      );
    }
    return _CoverList(onSelect: (item) => setState(() => _selected = item));
  }
}

// ── Cover list ────────────────────────────────────────────────────────────────

class _CoverList extends StatelessWidget {
  const _CoverList({required this.onSelect});

  final void Function(BarcodeItem) onSelect;

  @override
  Widget build(BuildContext context) {
    final barcodes = context.watch<BarcodeProvider>().filteredBarcodes;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceM,
                AppTheme.spaceM,
                AppTheme.spaceM,
                AppTheme.spaceS,
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_2_rounded,
                      color: AppTheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Barcodes',
                    style: AppTheme.titleLarge.copyWith(fontSize: 17),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${barcodes.length}',
                      style: AppTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppTheme.dividerColor),

            // ── List ─────────────────────────────────────────────────────────
            Expanded(
              child: barcodes.isEmpty
                  ? const _CoverEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spaceXS,
                      ),
                      itemCount: barcodes.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        indent: 48,
                        color: AppTheme.dividerColor,
                      ),
                      itemBuilder: (context, index) {
                        final item = barcodes[index];
                        return _CoverListTile(
                          item: item,
                          onTap: () => onSelect(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverListTile extends StatelessWidget {
  const _CoverListTile({required this.item, required this.onTap});

  final BarcodeItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceM,
          vertical: AppTheme.spaceS + 2,
        ),
        child: Row(
          children: [
            Icon(
              ScreenUtils.formatIcon(item.format),
              color: AppTheme.primary,
              size: 18,
            ),
            const SizedBox(width: AppTheme.spaceS),
            Expanded(
              child: Text(
                item.displayName,
                style: AppTheme.bodyLarge.copyWith(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppTheme.spaceXS),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                ScreenUtils.formatLabel(item.format),
                style: AppTheme.labelMedium.copyWith(fontSize: 9),
              ),
            ),
            const SizedBox(width: AppTheme.spaceXS),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppTheme.onSurfaceMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverEmptyState extends StatelessWidget {
  const _CoverEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spaceL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2_rounded,
                size: 40, color: AppTheme.onSurfaceMuted),
            SizedBox(height: AppTheme.spaceS),
            Text(
              'No barcodes saved',
              style: TextStyle(
                color: AppTheme.onSurfaceMuted,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
