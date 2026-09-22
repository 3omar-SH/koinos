import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Koinos/feature/task/data/model/task_model.dart';
import 'package:Koinos/feature/task/data/repos/task_repos.dart';
import 'package:Koinos/feature/auth/data/model/user_model.dart';
import 'package:Koinos/feature/workspace/data/repos/workspace_repos.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    WorkspaceRepository? workspaceRepository,
    TaskRepository? taskRepository,
  })  : _workspaceRepository = workspaceRepository ?? WorkspaceRepository(),
        _taskRepository = taskRepository ?? TaskRepository(),
        super(DashboardInitial());

  final WorkspaceRepository _workspaceRepository;
  final TaskRepository _taskRepository;
  StreamSubscription? _tasksSubscription;

  Future<void> initDashboard(String workspaceId) async {
    emit(DashboardLoading());

    try {
      final workspaceInfo = await _workspaceRepository.getWorkspaceInfo(workspaceId);
      final teamMembers = await _workspaceRepository.getTeamMembers(workspaceInfo.memberIds);

      _tasksSubscription?.cancel();
      _tasksSubscription = _taskRepository.streamTasks(workspaceId).listen(
        (tasks) => emit(_buildLoadedState(workspaceInfo.name, tasks, teamMembers)),
        onError: (error) {
          emit(DashboardError('Failed to load tasks: ${error.toString()}'));
        },
      );
    } catch (e) {
      emit(DashboardError('An error occurred: ${e.toString()}'));
    }
  }

  DashboardLoaded _buildLoadedState(
    String workspaceName,
    List<TaskModel> tasks,
    List<UserModel> teamMembers,
  ) {
    final total = tasks.length;
    final todo = tasks.where((t) => t.status == 'todo').length;
    final inProgress = tasks.where((t) => t.status == 'in_progress').length;
    final done = tasks.where((t) => t.status == 'done').length;
    final progress = total > 0 ? (done / total) : 0.0;

    return DashboardLoaded(
      workspaceName: workspaceName,
      tasks: tasks,
      teamMembers: teamMembers,
      totalTasks: total,
      inProgressTasks: inProgress,
      doneTasks: done,
      todoTasks: todo,
      sprintProgress: progress,
    );
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
