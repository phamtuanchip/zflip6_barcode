import 'package:flutter/material.dart';

import '../core/constants/app_theme.dart';
import '../core/utils/screen_utils.dart';
import '../models/barcode_item.dart';
import '../widgets/barcode_display.dart';

/// Full-screen detail view shown when a barcode is tapped on the Z Flip 6
/// cover screen.
///
/// Designed for the compact ~260 × 512 dp cover display:
/// - Black AMOLED background
/// - Large barcode display centred on screen
/// - Label and format shown below
/// - Back button at the top
class CoverBarcodeDetail extends StatelessWidget {
  const CoverBarcodeDetail({
    super.key,
    required this.item,
    required this.onBack,
  });

  final BarcodeItem item;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceS,
                vertical: AppTheme.spaceXS,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  Expanded(
                    child: Text(
                      item.displayName,
                      style: AppTheme.titleMedium.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppTheme.dividerColor),

            // ── Barcode ────────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceM),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BarcodeDisplay(
                      value: item.value,
                      format: item.format,
                      size: 180,
                    ),
                    const SizedBox(height: AppTheme.spaceM),

                    // Format chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceS,
                        vertical: AppTheme.spaceXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            ScreenUtils.formatIcon(item.format),
                            color: AppTheme.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ScreenUtils.formatLabel(item.format),
                            style: AppTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceS),

                    // Value text
                    Text(
                      item.value,
                      style: AppTheme.bodySmall.copyWith(fontSize: 10),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
