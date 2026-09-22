import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/feature/task/viewmodel/task_cubit.dart';
import 'package:Koinos/feature/task/viewmodel/task_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/tasks_header_widget.dart';
import '../widgets/tasks_filter_widget.dart';
import '../widgets/tasks_list_widget.dart';

class TasksScreen extends StatefulWidget {
  final String workspaceId;

  const TasksScreen({
    super.key,
    required this.workspaceId,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => TaskCubit()..initTask(widget.workspaceId),
      child: BlocListener<TaskCubit, TaskState>(
        listenWhen: (previous, current) =>
            current is TaskStateLoaded && current.errorMessage != null,
        listener: (context, state) {
          final message = (state as TaskStateLoaded).errorMessage!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.error),
          );
          context.read<TaskCubit>().clearActionError();
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                BlocBuilder<TaskCubit, TaskState>(
                  buildWhen: (previous, current) => current is TaskStateLoaded,
                  builder: (context, state) {
                    if (state is TaskStateLoaded) {
                      return TasksHeaderWidget(
                        isAdmin: state.isAdmin,
                        workspaceId: widget.workspaceId,
                        teamMembers: state.teamMembers,
                      );
                    }
                    return const SizedBox();
                  },
                ),

                const SizedBox(height: 20),

                BlocSelector<TaskCubit, TaskState, String>(
                  selector: (state) {
                    if (state is TaskStateLoaded) return state.currentFilter;
                    return 'All';
                  },
                  builder: (context, currentFilter) {
                    return TasksFilterWidget(currentFilter: currentFilter);
                  },
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: BlocBuilder<TaskCubit, TaskState>(
                    buildWhen: (previous, current) {
                      return current is TaskStateLoading ||
                          current is TaskStateLoaded ||
                          current is TaskStateError;
                    },
                    builder: (context, state) {
                      if (state is TaskStateLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryBlue),
                        );
                      }

                      if (state is TaskStateError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: TextStyle(color: theme.hintColor),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      if (state is TaskStateLoaded) {
                        if (state.tasksByAssignee.isEmpty) {
                          return Center(
                            child: Text(
                              'No tasks found.',
                              style: TextStyle(color: theme.hintColor),
                            ),
                          );
                        }

                        return TasksListWidget(groupedTasks: state.tasksByAssignee);
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
