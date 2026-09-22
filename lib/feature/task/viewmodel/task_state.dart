import 'package:Koinos/feature/task/data/model/task_model.dart';
import 'package:Koinos/feature/auth/data/model/user_model.dart';

abstract class TaskState {}

class TaskStateInitial extends TaskState {}

class TaskStateLoading extends TaskState {}

class TaskStateLoaded extends TaskState {
  final List<TaskModel> allTasks;
  final List<UserModel> teamMembers;
  final String currentFilter;
  final String searchQuery;
  final bool isAdmin;

  final String? errorMessage;

  Map<String, List<TaskModel>> get tasksByAssignee {
    final Map<String, List<TaskModel>> groupedTasks = {};

    var filteredTasks = currentFilter == 'All'
        ? allTasks
        : allTasks.where((task) => task.status == currentFilter).toList();

    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      filteredTasks =
          filteredTasks.where((task) => task.title.toLowerCase().contains(query)).toList();
    }

    for (var task in filteredTasks) {
      final assignee = task.assignedTo.isNotEmpty ? task.assignedTo : 'Unassigned';
      groupedTasks.putIfAbsent(assignee, () => []).add(task);
    }
    return groupedTasks;
  }

  TaskStateLoaded({
    required this.allTasks,
    required this.teamMembers,
    this.currentFilter = 'All',
    this.searchQuery = '',
    required this.isAdmin,
    this.errorMessage,
  });

  TaskStateLoaded copyWith({
    List<TaskModel>? allTasks,
    List<UserModel>? teamMembers,
    String? currentFilter,
    String? searchQuery,
    bool? isAdmin,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TaskStateLoaded(
      allTasks: allTasks ?? this.allTasks,
      teamMembers: teamMembers ?? this.teamMembers,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isAdmin: isAdmin ?? this.isAdmin,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TaskStateError extends TaskState {
  final String message;
  TaskStateError({required this.message});
}
