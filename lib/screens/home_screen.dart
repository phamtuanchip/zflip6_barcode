import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_theme.dart';
import '../models/barcode_item.dart';
import '../providers/barcode_provider.dart';
import '../screens/barcode_detail_screen.dart';
import '../screens/scanner_screen.dart';
import '../widgets/barcode_list_item.dart';

/// Main screen that shows the user's stored barcodes.
///
/// Features:
/// - Search bar in AppBar (toggle)
/// - Sort dropdown (newest, oldest, A-Z)
/// - Slidable list items (swipe to delete with undo)
/// - Empty-state illustration
/// - FAB to open the scanner
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSearch = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
  }

  void _openDetail(BuildContext context, BarcodeItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BarcodeDetailScreen(item: item)),
    );
  }

  Future<void> _deleteWithUndo(
    BuildContext context,
    BarcodeProvider provider,
    BarcodeItem item,
  ) async {
    await provider.deleteBarcode(item.id!);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.displayName} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppTheme.primary,
          onPressed: () async {
            // Re-insert with original id stripped (new row)
            await provider.addBarcode(item.copyWith(id: null));
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAll(
      BuildContext context, BarcodeProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        title: const Text('Delete all barcodes?'),
        content: const Text(
            'This will permanently remove all saved barcodes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
    if (confirmed == true) await provider.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BarcodeProvider>();
    final barcodes = provider.filteredBarcodes;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context, provider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openScanner(context),
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Scan'),
      ),
      body: Column(
        children: [
          if (_showSearch) _SearchBar(controller: _searchCtrl, provider: provider),
          Expanded(
            child: barcodes.isEmpty
                ? _EmptyState(isFiltered: provider.searchQuery.isNotEmpty)
                : _BarcodeList(
                    barcodes: barcodes,
                    onTap: (item) => _openDetail(context, item),
                    onDelete: (item) =>
                        _deleteWithUndo(context, provider, item),
                  ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, BarcodeProvider provider) {
    return AppBar(
      title: const Text('ZFlip6 Barcode'),
      actions: [
        // Sort button
        PopupMenuButton<SortOrder>(
          icon: const Icon(Icons.sort_rounded),
          tooltip: 'Sort',
          color: AppTheme.surfaceVariant,
          onSelected: provider.setSortOrder,
          itemBuilder: (_) => [
            _sortItem(SortOrder.newestFirst, 'Newest first',
                Icons.arrow_downward_rounded, provider.sortOrder),
            _sortItem(SortOrder.oldestFirst, 'Oldest first',
                Icons.arrow_upward_rounded, provider.sortOrder),
            _sortItem(SortOrder.labelAZ, 'Label A–Z',
                Icons.sort_by_alpha_rounded, provider.sortOrder),
          ],
        ),
        // Search toggle
        IconButton(
          icon: Icon(
            _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
          ),
          tooltip: 'Search',
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchCtrl.clear();
                provider.setSearch('');
              }
            });
          },
        ),
        // Delete all
        if (provider.totalCount > 0)
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Delete all',
            onPressed: () => _confirmDeleteAll(context, provider),
          ),
      ],
    );
  }

  PopupMenuItem<SortOrder> _sortItem(
    SortOrder value,
    String label,
    IconData icon,
    SortOrder current,
  ) {
    final selected = value == current;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: selected ? AppTheme.primary : AppTheme.onSurface),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                color: selected ? AppTheme.primary : AppTheme.onSurface,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              )),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.provider});
  final TextEditingController controller;
  final BarcodeProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceM,
        AppTheme.spaceS,
        AppTheme.spaceM,
        AppTheme.spaceXS,
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: provider.setSearch,
        style: AppTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search label or value…',
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppTheme.onSurfaceMuted, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppTheme.onSurfaceMuted, size: 18),
                  onPressed: () {
                    controller.clear();
                    provider.setSearch('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class _BarcodeList extends StatelessWidget {
  const _BarcodeList({
    required this.barcodes,
    required this.onTap,
    required this.onDelete,
  });

  final List<BarcodeItem> barcodes;
  final void Function(BarcodeItem) onTap;
  final void Function(BarcodeItem) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        top: AppTheme.spaceS,
        bottom: AppTheme.spaceXL + 56, // account for FAB
      ),
      itemCount: barcodes.length,
      itemBuilder: (context, index) {
        final item = barcodes[index];
        return BarcodeListItem(
          key: ValueKey(item.id),
          item: item,
          onTap: () => onTap(item),
          onDelete: () => onDelete(item),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isFiltered});
  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFiltered
                  ? Icons.search_off_rounded
                  : Icons.qr_code_2_rounded,
              size: 72,
              color: AppTheme.onSurfaceMuted,
            ),
            const SizedBox(height: AppTheme.spaceM),
            Text(
              isFiltered ? 'No barcodes match your search' : 'No barcodes yet',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.onSurfaceMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceS),
            Text(
              isFiltered
                  ? 'Try a different keyword'
                  : 'Tap the Scan button below to scan your first barcode',
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
