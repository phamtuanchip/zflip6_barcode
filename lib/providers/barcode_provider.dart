import 'package:flutter/foundation.dart';

import '../core/database/database_helper.dart';
import '../models/barcode_item.dart';

/// Sort order options for the barcode list.
enum SortOrder {
  newestFirst,
  oldestFirst,
  labelAZ,
}

/// [ChangeNotifier] that manages the in-memory barcode list and exposes
/// filtered / sorted views of it to the UI.
class BarcodeProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<BarcodeItem> _barcodes = [];
  String _searchQuery = '';
  SortOrder _sortOrder = SortOrder.newestFirst;

  // ── Getters ──────────────────────────────────────────────────────────────────

  String get searchQuery => _searchQuery;
  SortOrder get sortOrder => _sortOrder;

  /// The list after applying [_searchQuery] and [_sortOrder].
  List<BarcodeItem> get filteredBarcodes {
    var result = List<BarcodeItem>.from(_barcodes);

    // Filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((b) {
        return b.label.toLowerCase().contains(q) ||
            b.value.toLowerCase().contains(q);
      }).toList();
    }

    // Sort
    switch (_sortOrder) {
      case SortOrder.newestFirst:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortOrder.oldestFirst:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case SortOrder.labelAZ:
        result.sort((a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    }

    return result;
  }

  int get totalCount => _barcodes.length;

  // ── Mutations ────────────────────────────────────────────────────────────────

  Future<void> loadBarcodes() async {
    _barcodes = await _db.getAllBarcodes();
    notifyListeners();
  }

  /// Returns `true` if the barcode was inserted, `false` if it was a duplicate.
  Future<bool> addBarcode(BarcodeItem item) async {
    final exists = await _db.barcodeExists(item.value);
    if (exists) return false;

    final id = await _db.insertBarcode(item);
    _barcodes.insert(0, item.copyWith(id: id));
    notifyListeners();
    return true;
  }

  Future<void> updateLabel(int id, String label) async {
    await _db.updateBarcodeLabel(id, label);
    final index = _barcodes.indexWhere((b) => b.id == id);
    if (index != -1) {
      _barcodes[index].label = label;
      notifyListeners();
    }
  }

  Future<void> deleteBarcode(int id) async {
    await _db.deleteBarcode(id);
    _barcodes.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await _db.deleteAllBarcodes();
    _barcodes.clear();
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }
}
