import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  static const dbName = 'event_planner.db'; // เปลี่ยนชื่อ DB
  static const dbVersion = 1;
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dbDir = await getDatabasesPath();
    final dbPath = p.join(dbDir, dbName);
    return openDatabase(
      dbPath,
      version: dbVersion,
      onConfigure: (db) async {
        // เปิด Foreign Key Support [cite: 124]
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedData(db); // เพิ่มข้อมูลเริ่มต้น
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // 1. ตาราง Categories [cite: 593]
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        icon_key TEXT NOT NULL
      )
    ''');

    // 2. ตาราง Events [cite: 599]
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category_id INTEGER NOT NULL,
        event_date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        status TEXT NOT NULL,
        priority INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT
      )
    ''');
  }

  // สร้างข้อมูลตัวอย่าง 3 หมวดหมู่ ตามโจทย์ข้อ 7 (Testing Checklist) [cite: 630]
  Future<void> _seedData(Database db) async {
    await db.insert('categories', {
      'name': 'ทำงาน',
      'color_hex': 'FF2196F3', // Blue
      'icon_key': 'work',
    });
    await db.insert('categories', {
      'name': 'ส่วนตัว',
      'color_hex': 'FF4CAF50', // Green
      'icon_key': 'person',
    });
    await db.insert('categories', {
      'name': 'เร่งด่วน',
      'color_hex': 'FFF44336', // Red
      'icon_key': 'warning',
    });
  }
}