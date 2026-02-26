import 'package:flutter/foundation.dart';
import '../../data/models/category_model.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/app_repository.dart'; // Import นี้ต้องถูกต้อง

class EventStore extends ChangeNotifier {
  final AppRepository _repo = AppRepository();

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<EventModel> _events = [];
  List<EventModel> get events => _events;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  // --- Filter State ---
  DateTime? _filterDate; 
  String _filterStatus = 'All'; 
  int? _filterCategory; 

  // Getter ที่เพิ่มขึ้นมาเพื่อแก้ Error
  String get filterStatus => _filterStatus;
  DateTime? get filterDate => _filterDate;

  void init() {
    loadCategories();
    loadEvents();
  }

  Future<void> loadCategories() async {
    _categories = await _repo.getAllCategories();
    notifyListeners();
  }

  Future<void> loadEvents() async {
    _loading = true;
    notifyListeners();
    try {
      _events = await _repo.getEvents(
        dateFilter: _filterDate,
        status: _filterStatus,
        categoryFilter: _filterCategory,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addEvent(EventModel event) async {
    await _repo.insertEvent(event);
    loadEvents();
  }

  Future<void> updateEvent(EventModel event) async {
    await _repo.updateEvent(event);
    loadEvents();
  }

  Future<void> deleteEvent(int id) async {
    await _repo.deleteEvent(id);
    loadEvents();
  }

  Future<void> addCategory(CategoryModel cat) async {
    await _repo.insertCategory(cat);
    loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _repo.deleteCategory(id);
      loadCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void setDateFilter(DateTime? date) {
    _filterDate = date;
    loadEvents();
  }

  void setStatusFilter(String status) {
    _filterStatus = status;
    loadEvents();
  }
}