import 'package:flutter/material.dart';

import '../core/constants/app_theme.dart';
import '../core/utils/screen_utils.dart';
import '../models/barcode_item.dart';
import '../widgets/barcode_display.dart';

/// Full-screen detail view shown when a barcode is tapped on the Z Flip 6
/// cover screen.
///
/// Optimisations:
/// - [RepaintBoundary] around the [BarcodeDisplay] so safe-area / theme
///   rebuilds never touch the barcode painter.
/// - Slide-up + fade entry animation so the transition feels instant even
///   while the QR image is being rasterised in the background.
class CoverBarcodeDetail extends StatefulWidget {
  const CoverBarcodeDetail({
    super.key,
    required this.item,
    required this.onBack,
  });

  final BarcodeItem item;
  final VoidCallback onBack;

  @override
  State<CoverBarcodeDetail> createState() => _CoverBarcodeDetailState();
}

class _CoverBarcodeDetailState extends State<CoverBarcodeDetail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();

  late final Animation<double> _fade =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ───────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceS,
                    vertical: AppTheme.spaceXS,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      Expanded(
                        child: Text(
                          widget.item.displayName,
                          style: AppTheme.titleMedium.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: AppTheme.dividerColor),

                // ── Barcode ──────────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceM),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // RepaintBoundary ensures the barcode painter is
                        // fully isolated from any ancestor rebuild.
                        RepaintBoundary(
                          child: BarcodeDisplay(
                            value: widget.item.value,
                            format: widget.item.format,
                            size: 180,
                          ),
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
                                ScreenUtils.formatIcon(widget.item.format),
                                color: AppTheme.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ScreenUtils.formatLabel(widget.item.format),
                                style: AppTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceS),

                        // Value text
                        Text(
                          widget.item.value,
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
        ),
      ),
    );
  }
}
