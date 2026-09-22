// ignore_for_file: deprecated_member_use

import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/feature/task/data/model/task_model.dart';
import 'package:Koinos/feature/task/viewmodel/task_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserTaskGroupCard extends StatefulWidget {
  final String assignee;
  final List<TaskModel> tasks;

  const UserTaskGroupCard({super.key, required this.assignee, required this.tasks});

  @override
  State<UserTaskGroupCard> createState() => _UserTaskGroupCardState();
}

class _UserTaskGroupCardState extends State<UserTaskGroupCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalTasks = widget.tasks.length;
    final doneTasks = widget.tasks.where((t) => t.status == 'done').length;
    final progress = totalTasks > 0 ? (doneTasks / totalTasks) : 0.0;

    final initial = widget.assignee != 'Unassigned' && widget.assignee.isNotEmpty
        ? widget.assignee[0].toUpperCase()
        : 'U';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.gradientGreen.withOpacity(0.15),
                    child: Text(
                      initial,
                      style: const TextStyle(color: AppColors.gradientGreen, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.assignee,
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: theme.hintColor.withOpacity(0.2),
                                  color: AppColors.gradientGreen,
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$doneTasks/$totalTasks done',
                              style: TextStyle(color: theme.hintColor, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.gradientGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$totalTasks',
                      style: const TextStyle(color: AppColors.gradientGreen, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: theme.hintColor,
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: widget.tasks
                    .map((task) => _buildTaskRow(task, theme))
                    .toList(growable: false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskRow(TaskModel task, ThemeData theme) {
    Color statusColor = AppColors.taskTodo;
    IconData statusIcon = Icons.circle_outlined;

    if (task.status == 'in_progress') {
      statusColor = AppColors.taskInProgress;
      statusIcon = Icons.timelapse_rounded;
    } else if (task.status == 'done') {
      statusColor = AppColors.taskDone;
      statusIcon = Icons.check_circle_rounded;
    }

    Color priorityColor = theme.hintColor;
    if (task.priority == 'High') priorityColor = AppColors.error;
    if (task.priority == 'Medium') priorityColor = AppColors.gradientOrange;
    if (task.priority == 'Low') priorityColor = AppColors.gradientCyan;

    final dateString = "${task.dueDate.day} / ${task.dueDate.month}";

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(top: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete task'),
                content: Text('Delete "${task.title}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        context.read<TaskCubit>().deleteTask(task);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.read<TaskCubit>().cycleTaskStatus(task),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  decoration: task.status == 'done' ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Text(
              dateString,
              style: TextStyle(color: theme.hintColor, fontSize: 12),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                task.priority,
                style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
