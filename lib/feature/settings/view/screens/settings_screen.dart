import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/feature/settings/view/widgets/settings_member_tile.dart';
import 'package:Koinos/feature/settings/viewmodel/settings_cubit.dart';
import 'package:Koinos/feature/settings/viewmodel/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  final String workspaceId;
  const SettingsScreen({super.key, required this.workspaceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit()..initSettings(workspaceId),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  Future<void> _editWorkspaceName(BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Workspace name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter workspace name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.trim().isNotEmpty && context.mounted) {
      context.read<SettingsCubit>().renameWorkspace(newName);
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<SettingsCubit>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error),
          );
          context.read<SettingsCubit>().clearActionError();
        }
      },
      builder: (context, state) {
        if (state is SettingsLoading || state is SettingsInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }

        if (state is SettingsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.hintColor),
              ),
            ),
          );
        }

        final loaded = state as SettingsLoaded;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader('Workspace'),
              const SizedBox(height: 10),
              _SettingsTile(
                icon: Icons.workspaces_outline,
                title: loaded.workspaceName,
                subtitle: loaded.isAdmin ? 'Tap to rename' : null,
                trailing: loaded.isAdmin
                    ? const Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryBlue)
                    : null,
                onTap: loaded.isAdmin
                    ? () => _editWorkspaceName(context, loaded.workspaceName)
                    : null,
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionHeader('Members (${loaded.members.length})'),
                ],
              ),
              const SizedBox(height: 10),
              if (loaded.members.isEmpty)
                Text('No members yet', style: TextStyle(color: theme.hintColor))
              else
                ...loaded.members.map(
                  (member) => SettingsMemberTile(
                    member: member,
                    isAdminAccount: member.uid == loaded.adminId,
                    canRemove: loaded.isAdmin && member.uid != loaded.adminId,
                    isRemoving: loaded.removingMemberId == member.uid,
                  ),
                ),

              const SizedBox(height: 24),
              _SectionHeader('Account'),
              const SizedBox(height: 10),
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Sign out',
                titleColor: AppColors.error,
                onTap: () => _confirmSignOut(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            Icon(icon, color: titleColor ?? AppColors.primaryBlue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: TextStyle(color: theme.hintColor, fontSize: 12)),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
