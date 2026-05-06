import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_theme.dart';
import '../core/utils/screen_utils.dart';
import '../models/barcode_item.dart';

/// A single row in the barcode list on [HomeScreen].
///
/// Supports swipe-left to delete via [flutter_slidable].
class BarcodeListItem extends StatelessWidget {
  const BarcodeListItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final BarcodeItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppTheme.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(AppTheme.radiusMedium),
              bottomRight: Radius.circular(AppTheme.radiusMedium),
            ),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceM,
              vertical: AppTheme.spaceXS + 2,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceM,
              vertical: AppTheme.spaceM - 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.dividerColor, width: 0.5),
            ),
            child: Row(
              children: [
                _FormatIcon(format: item.format),
                const SizedBox(width: AppTheme.spaceM),
                Expanded(child: _ItemText(item: item)),
                const SizedBox(width: AppTheme.spaceS),
                Text(
                  _dateFormat.format(item.createdAt),
                  style: AppTheme.bodySmall,
                ),
                const SizedBox(width: AppTheme.spaceXS),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppTheme.onSurfaceMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormatIcon extends StatelessWidget {
  const _FormatIcon({required this.format});
  final String format;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall + 2),
      ),
      child: Icon(
        ScreenUtils.formatIcon(format),
        color: AppTheme.primary,
        size: 22,
      ),
    );
  }
}

class _ItemText extends StatelessWidget {
  const _ItemText({required this.item});
  final BarcodeItem item;

  @override
  Widget build(BuildContext context) {
    final hasLabel = item.label.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.displayName,
          style: AppTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _FormatChip(format: item.format),
            if (hasLabel) ...[
              const SizedBox(width: AppTheme.spaceXS),
              Expanded(
                child: Text(
                  item.shortValue,
                  style: AppTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip({required this.format});
  final String format;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        ScreenUtils.formatLabel(format),
        style: AppTheme.labelMedium.copyWith(fontSize: 10),
      ),
    );
  }
}
