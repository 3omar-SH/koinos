import 'package:Koinos/feature/task/data/model/task_model.dart';
import 'package:Koinos/feature/auth/data/model/user_model.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final String workspaceName;
  final List<TaskModel> tasks;
  final List<UserModel> teamMembers;
  final int totalTasks;
  final int inProgressTasks;
  final int doneTasks;
  final int todoTasks;
  final double sprintProgress;

  DashboardLoaded({
    required this.workspaceName,
    required this.tasks,
    required this.teamMembers,
    required this.totalTasks,
    required this.inProgressTasks,
    required this.doneTasks,
    required this.todoTasks,
    required this.sprintProgress,
  });
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
