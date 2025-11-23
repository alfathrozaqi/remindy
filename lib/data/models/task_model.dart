class TaskModel {
  final int? id;
  final String title;
  final String description;
  final DateTime deadline;
  final String category;
  final int priority;
  final bool isReminderActive;
  final int isCompleted; 

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.category,
    required this.priority,
    required this.isReminderActive,
    this.isCompleted = 0,
  });

  // Konversi dari Map (Database) ke Object TaskModel
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      deadline: DateTime.parse(map['deadline']),
      category: map['category'],
      priority: map['priority'],
      isReminderActive: map['is_reminder_active'] == 1,
      isCompleted: map['is_completed'],
    );
  }

  // Konversi dari Object TaskModel ke Map (untuk simpan ke Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'category': category,
      'priority': priority,
      'is_reminder_active': isReminderActive ? 1 : 0,
      'is_completed': isCompleted,
    };
  }

  // Helper untuk menduplikasi object dengan nilai baru (berguna saat update status)
  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? deadline,
    String? category,
    int? priority,
    bool? isReminderActive,
    int? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isReminderActive: isReminderActive ?? this.isReminderActive,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}