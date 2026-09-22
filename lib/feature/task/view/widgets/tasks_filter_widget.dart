// ignore_for_file: deprecated_member_use

import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/feature/task/viewmodel/task_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TasksFilterWidget extends StatelessWidget {
  final String currentFilter;

  const TasksFilterWidget({super.key, required this.currentFilter});

  static const Map<String, String> _filters = {
    'All': 'All',
    'todo': 'Todo',
    'in_progress': 'In Progress',
    'done': 'Done',
  };

  @override
  Widget build(BuildContext context) {
    final filterKeys = _filters.keys.toList();

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filterKeys.length,
        itemBuilder: (context, index) {
          String filterKey = filterKeys[index];
          String filterDisplayName = _filters[filterKey]!;

          bool isSelected = filterKey == currentFilter;

          return GestureDetector(
            onTap: () {
              context.read<TaskCubit>().changeFilter(filterKey);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : Colors.grey.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  filterDisplayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).hintColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
