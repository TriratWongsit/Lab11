import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/category_model.dart';
import '../models/event_model.dart';

class AppRepository {
  // --- Category Operations ---
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('categories');
    return rows.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<int> insertCategory(CategoryModel cat) async {
    final db = await AppDatabase.instance.database;
    return db.insert('categories', cat.toMap()..remove('id'));
  }

  Future<int> deleteCategory(int id) async {
    final db = await AppDatabase.instance.database;
    // เช็คว่ามี Event ใช้งานอยู่ไหม
    final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM events WHERE category_id = ?', [id]));
    
    if (count != null && count > 0) {
      throw Exception('ไม่สามารถลบได้ เนื่องจากมีกิจกรรมในหมวดหมู่นี้');
    }
    return db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // --- Event Operations ---
  Future<List<EventModel>> getEvents({
    String? searchQuery, 
    String? status, 
    DateTime? dateFilter,
    int? categoryFilter,
    bool orderByDate = true
  }) async {
    final db = await AppDatabase.instance.database;
    String whereClause = '1=1'; 
    List<dynamic> args = [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause += ' AND title LIKE ?';
      args.add('%$searchQuery%');
    }
    if (status != null && status != 'All') {
      whereClause += ' AND status = ?';
      args.add(status);
    }
    if (categoryFilter != null) {
      whereClause += ' AND category_id = ?';
      args.add(categoryFilter);
    }
    if (dateFilter != null) {
      whereClause += ' AND event_date LIKE ?';
      args.add('${dateFilter.toIso8601String().split("T")[0]}%');
    }

    String orderBy = orderByDate 
        ? 'event_date ASC, start_time ASC' 
        : 'id DESC';

    final rows = await db.query(
      'events',
      where: whereClause,
      whereArgs: args,
      orderBy: orderBy,
    );
    return rows.map((e) => EventModel.fromMap(e)).toList();
  }

  Future<int> insertEvent(EventModel event) async {
    final db = await AppDatabase.instance.database;
    return db.insert('events', event.toMap()..remove('id'));
  }

  Future<int> updateEvent(EventModel event) async {
    final db = await AppDatabase.instance.database;
    return db.update('events', event.toMap(),
        where: 'id = ?', whereArgs: [event.id]);
  }

  Future<int> deleteEvent(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}