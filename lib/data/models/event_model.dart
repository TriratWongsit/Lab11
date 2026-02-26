class EventModel {
  final int? id;
  final String title;
  final String description;
  final int categoryId; // FK เชื่อมกับ Category
  final DateTime eventDate; // วันที่
  final String startTime;   // HH:mm
  final String endTime;     // HH:mm
  final String status;      // pending, in_progress, completed, cancelled
  final int priority;       // 1=Low, 2=Normal, 3=High

  EventModel({
    this.id,
    required this.title,
    this.description = '',
    required this.categoryId,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'event_date': eventDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'priority': priority,
    };
  }

  static EventModel fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      categoryId: map['category_id'],
      eventDate: DateTime.parse(map['event_date']),
      startTime: map['start_time'],
      endTime: map['end_time'],
      status: map['status'],
      priority: map['priority'],
    );
  }
  
  // Helper สำหรับเช็คสถานะ
  bool get isCompleted => status == 'completed';
}