// ignore_for_file: deprecated_member_use

import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/feature/groups/data/model/group_model.dart';
import 'package:Koinos/feature/groups/viewmodel/group_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class WorkspaceCard extends StatelessWidget {
  final GroupModel group;
  final Color cardColor;
  final bool isDarkMode;
  final String currentUserId;

  const WorkspaceCard({
    required this.group,
    required this.cardColor,
    required this.isDarkMode,
    required this.currentUserId,
  });

  void _showActionDialog(BuildContext context) {
    final bool isAdmin = group.adminId == currentUserId;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isAdmin ? "Delete Workspace" : "Leave Workspace"),
          content: Text(
            isAdmin
                ? "Are you sure you want to delete this workspace?"
                : "Are you sure you want to leave this workspace?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (isAdmin) {
                  context.read<GroupCubit>().deleteGroup(group.id);
                } else {
                  context
                      .read<GroupCubit>()
                      .leaveGroup(group.id);
                }
              },
              child: Text(
                isAdmin ? "Delete" : "Leave",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: cardColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push('/workspace/${group.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    color: cardColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Code: ${group.groupCode}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.group_remove_outlined),
                  color: AppColors.textMuted.withOpacity(0.6),
                  onPressed: () => _showActionDialog(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
