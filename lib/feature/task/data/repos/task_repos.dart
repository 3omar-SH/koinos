import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/task_model.dart';

class TaskRepository {
  TaskRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<TaskModel>> streamTasks(String workspaceId) {
    return _firestore
        .collection('tasks')
        .where('workspaceId', isEqualTo: workspaceId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addTask(TaskModel task) async {
    await _firestore.collection('tasks').add(task.toMap());
  }

  Future<void> updateTaskStatus(TaskModel task) async {
    await _firestore.collection('tasks').doc(task.id).update({'status': task.status});
  }

  Future<void> deleteTask(TaskModel task) async {
    await _firestore.collection('tasks').doc(task.id).delete();
  }
}
