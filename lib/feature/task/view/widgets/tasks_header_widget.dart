// ignore_for_file: deprecated_member_use

import 'package:Koinos/feature/auth/data/model/user_model.dart';
import 'package:Koinos/feature/task/viewmodel/task_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_task_sheet.dart';

class TasksHeaderWidget extends StatefulWidget {
  final bool isAdmin;
  final String workspaceId;
  final List<UserModel> teamMembers;

  const TasksHeaderWidget({
    super.key,
    required this.isAdmin,
    required this.workspaceId,
    required this.teamMembers,
  });

  @override
  State<TasksHeaderWidget> createState() => _TasksHeaderWidgetState();
}

class _TasksHeaderWidgetState extends State<TasksHeaderWidget> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                width: 1.5,
              ),
              boxShadow: isDark ? [] : [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<TaskCubit>().search(value);
              },
              style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: TextStyle(color: theme.hintColor, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: theme.hintColor, size: 20),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.close, color: theme.hintColor, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          context.read<TaskCubit>().search('');
                        },
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              ),
            ),
          ),
        ),

        if (widget.isAdmin) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => BlocProvider.value(
                  value: context.read<TaskCubit>(),
                  child: AddTaskSheet(workspaceId: widget.workspaceId, teamMembers: widget.teamMembers),
                ),
              );
            },
            child: Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF7C82F8),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF7C82F8).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 26),
            ),
          ),
        ]
      ],
    );
  }
}
