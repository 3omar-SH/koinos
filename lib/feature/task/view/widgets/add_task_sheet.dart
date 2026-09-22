// ignore_for_file: deprecated_member_use

import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/feature/task/viewmodel/task_cubit.dart';
import 'package:Koinos/feature/auth/data/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddTaskSheet extends StatefulWidget {
  final String workspaceId;
  final List<UserModel> teamMembers;

  const AddTaskSheet({super.key, required this.workspaceId, required this.teamMembers});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _titleController = TextEditingController();
  String _selectedAssigneeEmail = 'Unassigned';
  String _selectedPriority = 'Medium';
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submitTask() {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<TaskCubit>().addTask(
          title: title,
          assignedTo: _selectedAssigneeEmail,
          priority: _selectedPriority,
          workspaceId: widget.workspaceId,
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.black.withOpacity(0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
    );

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create New Task', style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          TextFormField(
            controller: _titleController,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            decoration: inputDecoration.copyWith(
              hintText: 'Task Title',
              hintStyle: TextStyle(color: theme.hintColor),
              prefixIcon: Icon(Icons.title, color: theme.hintColor),
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedAssigneeEmail,
            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            decoration: inputDecoration.copyWith(
              hintText: 'Select Assignee',
              hintStyle: TextStyle(color: theme.hintColor),
              prefixIcon: Icon(Icons.person_outline, color: theme.hintColor),
            ),
            items: [
              const DropdownMenuItem(
                value: 'Unassigned',
                child: Text('Unassigned'),
              ),
              ...widget.teamMembers.map((user) {
                return DropdownMenuItem(
                  value: user.username,
                  child: Text(user.username),
                );
              }),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedAssigneeEmail = val;
                });
              }
            },
          ),
          const SizedBox(height: 24),

          Text('Priority', style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _priorities.map((priority) {
              final isSelected = _selectedPriority == priority;
              Color priorityColor = AppColors.gradientOrange;
              if (priority == 'High') priorityColor = AppColors.error;
              if (priority == 'Low') priorityColor = AppColors.gradientCyan;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPriority = priority),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? priorityColor.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? priorityColor : theme.hintColor.withOpacity(0.2)),
                    ),
                    child: Center(
                      child: Text(priority, style: TextStyle(color: isSelected ? priorityColor : theme.hintColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C82F8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _submitTask,
              child: const Text('Add Task', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
