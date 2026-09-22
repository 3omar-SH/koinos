import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String status;
  final String priority;
  final String assignedTo;
  final String workspaceId;
  final DateTime dueDate;

  TaskModel({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.assignedTo,
    required this.workspaceId,
    required this.dueDate,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      status: map['status'] ?? 'todo',
      priority: map['priority'] ?? 'Medium',
      assignedTo: map['assignedTo'] ?? '',
      workspaceId: map['workspaceId'] ?? '',
      dueDate: (map['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status,
      'priority': priority,
      'assignedTo': assignedTo,
      'workspaceId': workspaceId,
      'dueDate': Timestamp.fromDate(dueDate),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? status,
    String? priority,
    String? assignedTo,
    String? workspaceId,
    DateTime? dueDate,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      workspaceId: workspaceId ?? this.workspaceId,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
