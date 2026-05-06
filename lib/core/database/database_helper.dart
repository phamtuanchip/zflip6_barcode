import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/barcode_item.dart';

/// Singleton wrapper around the [sqflite] database.
///
/// Table schema:
/// ```
/// barcodes (
///   id        INTEGER PRIMARY KEY AUTOINCREMENT,
///   value     TEXT    NOT NULL,
///   format    TEXT    NOT NULL,
///   label     TEXT    NOT NULL DEFAULT '',
///   created_at INTEGER NOT NULL
/// )
/// ```
class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  static const _dbName = 'zflip6_barcodes.db';
  static const _dbVersion = 1;
  static const _tableName = 'barcodes';

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        value      TEXT    NOT NULL,
        format     TEXT    NOT NULL,
        label      TEXT    NOT NULL DEFAULT '',
        created_at INTEGER NOT NULL
      )
    ''');
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────────

  /// Inserts a [BarcodeItem] and returns the new row id.
  Future<int> insertBarcode(BarcodeItem item) async {
    final db = await database;
    return db.insert(
      _tableName,
      item.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns all barcodes ordered by [created_at] descending.
  Future<List<BarcodeItem>> getAllBarcodes() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'created_at DESC');
    return maps.map(BarcodeItem.fromMap).toList();
  }

  /// Updates the [label] of a barcode identified by [id].
  Future<int> updateBarcodeLabel(int id, String label) async {
    final db = await database;
    return db.update(
      _tableName,
      {'label': label},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a barcode by [id].  Returns the number of rows deleted.
  Future<int> deleteBarcode(int id) async {
    final db = await database;
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes every barcode in the table.
  Future<int> deleteAllBarcodes() async {
    final db = await database;
    return db.delete(_tableName);
  }

  /// Returns `true` if a barcode with this exact [value] already exists.
  Future<bool> barcodeExists(String value) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      columns: ['id'],
      where: 'value = ?',
      whereArgs: [value],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
