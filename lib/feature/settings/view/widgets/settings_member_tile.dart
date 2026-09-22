import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/feature/auth/data/model/user_model.dart';
import 'package:Koinos/feature/settings/viewmodel/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsMemberTile extends StatelessWidget {
  final UserModel member;
  final bool isAdminAccount;
  final bool canRemove;
  final bool isRemoving;

  const SettingsMemberTile({
    super.key,
    required this.member,
    required this.isAdminAccount,
    required this.canRemove,
    required this.isRemoving,
  });

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove member'),
        content: Text('Remove "${member.username}" from this workspace? '
            'They will lose access to its tasks and chat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<SettingsCubit>().removeMember(member);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final initial = member.username.isNotEmpty ? member.username[0].toUpperCase() : 'U';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.username,
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (isAdminAccount) ...[
                  const SizedBox(height: 2),
                  const Text(
                    'Admin',
                    style: TextStyle(color: AppColors.primaryBlue, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (canRemove)
            isRemoving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                  )
                : IconButton(
                    icon: const Icon(Icons.person_remove_outlined, color: AppColors.error),
                    tooltip: 'Remove member',
                    onPressed: () => _confirmRemove(context),
                  ),
        ],
      ),
    );
  }
}
