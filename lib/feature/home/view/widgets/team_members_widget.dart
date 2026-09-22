// ignore_for_file: deprecated_member_use

import 'package:Koinos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:Koinos/feature/auth/data/model/user_model.dart';

class TeamMembersWidget extends StatelessWidget {
  final List<UserModel> members;

  const TeamMembersWidget({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final displayCount = members.length > 4 ? 4 : members.length;
    final extraCount = members.length > 4 ? members.length - 4 : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Team Members',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            if (members.isNotEmpty)
              SizedBox(
                height: 32,
                width: 32.0 * displayCount - (14.0 * (displayCount - 1)) + (extraCount > 0 ? 24 : 0),
                child: Stack(
                  children: [
                    ...List.generate(displayCount, (index) {
                      final user = members[index];
                      final initial = user.username.isNotEmpty
                          ? user.username[0].toUpperCase()
                          : 'U';

                      return Positioned(
                        right: index * 18.0 + (extraCount > 0 ? 18.0 : 0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 13.5,
                            backgroundColor: AppColors.workspaceColors[index % AppColors.workspaceColors.length],
                            child: Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    if (extraCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 13.5,
                            backgroundColor: theme.colorScheme.surface,
                            child: Text(
                              '+$extraCount',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(width: 8),

            GestureDetector(
              onTap: () {
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 16),
              ),
            )
          ],
        )
      ],
    );
  }
}
