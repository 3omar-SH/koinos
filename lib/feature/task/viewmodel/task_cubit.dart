import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Koinos/feature/task/data/repos/task_repos.dart';
import 'package:Koinos/feature/task/viewmodel/task_state.dart';
import 'package:Koinos/feature/task/data/model/task_model.dart';
import 'package:Koinos/feature/workspace/data/repos/workspace_repos.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit({
    TaskRepository? taskRepository,
    WorkspaceRepository? workspaceRepository,
  })  : _taskRepository = taskRepository ?? TaskRepository(),
        _workspaceRepository = workspaceRepository ?? WorkspaceRepository(),
        super(TaskStateInitial());

  final TaskRepository _taskRepository;
  final WorkspaceRepository _workspaceRepository;
  StreamSubscription? _tasksSubscription;

  Future<void> initTask(String workspaceId) async {
    emit(TaskStateLoading());
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    try {
      final workspaceInfo = await _workspaceRepository.getWorkspaceInfo(workspaceId);
      final isUserAdmin = currentUserUid == workspaceInfo.adminId;
      final teamMembers = await _workspaceRepository.getTeamMembers(workspaceInfo.memberIds);

      _tasksSubscription?.cancel();
      _tasksSubscription = _taskRepository.streamTasks(workspaceId).listen(
        (tasks) {
          String activeFilter = 'All';
          String activeSearch = '';
          final current = state;
          if (current is TaskStateLoaded) {
            activeFilter = current.currentFilter;
            activeSearch = current.searchQuery;
          }

          emit(TaskStateLoaded(
            allTasks: tasks,
            teamMembers: teamMembers,
            currentFilter: activeFilter,
            searchQuery: activeSearch,
            isAdmin: isUserAdmin,
          ));
        },
        onError: (error) {
          emit(TaskStateError(message: error.toString()));
        },
      );
    } catch (e) {
      emit(TaskStateError(message: e.toString()));
    }
  }

  void changeFilter(String newFilter) {
    final current = state;
    if (current is TaskStateLoaded) {
      emit(current.copyWith(currentFilter: newFilter, clearError: true));
    }
  }

  void search(String query) {
    final current = state;
    if (current is TaskStateLoaded) {
      emit(current.copyWith(searchQuery: query, clearError: true));
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    try {
      await _taskRepository.deleteTask(task);
    } catch (e) {
      _emitActionError('Failed to delete task: ${e.toString()}');
    }
  }

  Future<void> cycleTaskStatus(TaskModel task) async {
    const order = ['todo', 'in_progress', 'done'];
    final currentIndex = order.indexOf(task.status);
    final nextStatus = order[(currentIndex + 1) % order.length];

    try {
      await _taskRepository.updateTaskStatus(task.copyWith(status: nextStatus));
    } catch (e) {
      _emitActionError('Failed to update task: ${e.toString()}');
    }
  }

  Future<void> addTask({
    required String title,
    required String assignedTo,
    required String priority,
    required String workspaceId,
  }) async {
    try {
      final newTask = TaskModel(
        id: '',
        title: title,
        status: 'todo',
        priority: priority,
        assignedTo: assignedTo,
        workspaceId: workspaceId,
        dueDate: DateTime.now(),
      );
      await _taskRepository.addTask(newTask);
    } catch (e) {
      _emitActionError('Failed to add task: ${e.toString()}');
    }
  }

  void clearActionError() {
    final current = state;
    if (current is TaskStateLoaded && current.errorMessage != null) {
      emit(current.copyWith(clearError: true));
    }
  }

  void _emitActionError(String message) {
    final current = state;
    if (current is TaskStateLoaded) {
      emit(current.copyWith(errorMessage: message));
    } else {
      emit(TaskStateError(message: message));
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
