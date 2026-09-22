import 'package:Koinos/feature/task/data/model/task_model.dart';
import 'package:flutter/material.dart';
import 'user_task_group_card.dart';

class TasksListWidget extends StatelessWidget {
  final Map<String, List<TaskModel>> groupedTasks;

  const TasksListWidget({super.key, required this.groupedTasks});

  @override
  Widget build(BuildContext context) {
    final assignees = groupedTasks.keys.toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: assignees.length,
      itemBuilder: (context, index) {
        final assignee = assignees[index];
        final tasks = groupedTasks[assignee]!;

        return Padding(
          key: ValueKey(assignee),
          padding: const EdgeInsets.only(bottom: 16.0),
          child: UserTaskGroupCard(assignee: assignee, tasks: tasks),
        );
      },
    );
  }
}
