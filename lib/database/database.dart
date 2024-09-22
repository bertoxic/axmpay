import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

class AdvancedLocalStorage {
  static final AdvancedLocalStorage instance = AdvancedLocalStorage._init();
  static Database? _database;
  final _lock = Lock();
  final Map<String, dynamic> _cache = {};

  AdvancedLocalStorage._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('advanced_local_storage.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: _configureDB,
    );
  }

  Future<void> _configureDB(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    _createUserDataTable(db);
  }

  Future<void> _createUserDataTable(Database db) async {
    const idType = 'INTEGER PRIMARY KEY';
    const textType = 'TEXT';
    const realType = 'REAL';
    const integerType = 'INTEGER';

    await db.execute('''
CREATE TABLE IF NOT EXISTS userdatatable (
  id $integerType,
  api_key $textType,
  refby $textType,
  verificationStatus $textType,
  Tier $textType,
  refLink $textType,
  vkey $textType,
  refStatus $textType,
  earn $textType,
  status $textType,
  phoneStatus $textType,
  emailStatus $textType,
  Type_ID $textType,
  BVN $textType,
  NIN $textType,
  type $textType,
  AID $textType,
  accountStatus $textType,
  fullName $textType,
  accountNumber $textType,
  customerID $textType,
  availableBalance $textType,
  ImageName $textType,
  firstname $textType,
  lastname $textType,
  DOB $textType,
  gender $textType,
  email $textType,
  phone $textType,
  country $textType,
  address $textType,
  username $textType,
  password $textType,
  Date $textType
)
''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // for our beloved migration logic
    }
  }

  Future<T> _withLock<T>(Future<T> Function() operation) async {
    return await _lock.synchronized(operation);
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    return await _withLock(() async {
      final db = await instance.database;
      final id = await db.insert(table, row);
      _invalidateCache(table);
      return id;
    });
  }

  Future<List<Map<String, dynamic>>> query(
      String table, {
        bool distinct = false,
        List<String>? columns,
        String? where,
        List<dynamic>? whereArgs,
        String? groupBy,
        String? having,
        String? orderBy,
        int? limit,
        int? offset,
      }) async {
    return await _withLock(() async {
      final cacheKey = _generateCacheKey(table, columns, where, whereArgs, orderBy, limit, offset);
      if (_cache.containsKey(cacheKey)) {
        return List<Map<String, dynamic>>.from(_cache[cacheKey]);
      }

      final db = await instance.database;
      final result = await db.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );

      _cache[cacheKey] = result;
      return result;
    });
  }

  Future<int> update(
      String table,
      Map<String, dynamic> row, {
        String? where,
        List<dynamic>? whereArgs,
      }) async {
    return await _withLock(() async {
      final db = await instance.database;
      final result = await db.update(table, row, where: where, whereArgs: whereArgs);
      _invalidateCache(table);
      return result;
    });
  }

  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    return await _withLock(() async {
      final db = await instance.database;
      final result = await db.delete(table, where: where, whereArgs: whereArgs);
      _invalidateCache(table);
      return result;
    });
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    return await _withLock(() async {
      final db = await instance.database;
      return await db.rawQuery(sql, arguments);
    });
  }

  Future<void> batch(void Function(Batch batch) actions) async {
    await _withLock(() async {
      final db = await instance.database;
      final batch = db.batch();
      actions(batch);
      await batch.commit(noResult: true);
      _invalidateCache(null);
    });
  }

  void _invalidateCache(String? table) {
    if (table == null) {
      _cache.clear();
    } else {
      _cache.removeWhere((key, _) => key.startsWith(table));
    }
  }

  String _generateCacheKey(
      String table,
      List<String>? columns,
      String? where,
      List<dynamic>? whereArgs,
      String? orderBy,
      int? limit,
      int? offset,
      ) {
    return '$table|${columns?.join(',')}|$where|${whereArgs?.join(',')}|$orderBy|$limit|$offset';
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}

// Extension for type-safe queries
extension TypeSafeQueries on AdvancedLocalStorage {
  Future<List<T>> queryTyped<T>(
      String table, {
        bool distinct = false,
        List<String>? columns,
        String? where,
        List<dynamic>? whereArgs,
        String? groupBy,
        String? having,
        String? orderBy,
        int? limit,
        int? offset,
        required T Function(Map<String, dynamic>) fromMap,
      }) async {
    final results = await query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return results.map((map) => fromMap(map)).toList();
  }
}