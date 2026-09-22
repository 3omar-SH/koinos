// ignore_for_file: deprecated_member_use

import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/core/widgets/app_drawer.dart';
import 'package:Koinos/feature/groups/data/model/group_model.dart';
import 'package:Koinos/feature/groups/view/widgets/workspace_card.dart';
import 'package:Koinos/feature/groups/viewmodel/group_cubit.dart';
import 'package:Koinos/feature/groups/viewmodel/group_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupsHubScreen extends StatefulWidget {
  const GroupsHubScreen({super.key});

  @override
  State<GroupsHubScreen> createState() => _GroupsHubScreenState();
}

class _GroupsHubScreenState extends State<GroupsHubScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    context.read<GroupCubit>().fetchGroups();
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _OptionsSheet(
        onCreateTap: () {
          Navigator.pop(context);
          _showGroupDialog(role: 'create');
        },
        onJoinTap: () {
          Navigator.pop(context);
          _showGroupDialog(role: 'join');
        },
      ),
    );
  }

  void _showGroupDialog({required String role}) {
    final controller = TextEditingController();
    final isCreate = role == 'create';

    showDialog(
      context: context,
      builder: (dialogContext) => _GroupDialog(
        isCreate: isCreate,
        controller: controller,
        onConfirm: () {
          if (controller.text.trim().isNotEmpty) {
            if (isCreate) {
              context.read<GroupCubit>().createGroup(name: controller.text.trim());
            } else {
              context.read<GroupCubit>().joinGroup(groupCode: controller.text.trim());
            }
            Navigator.of(dialogContext).pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isCreate ? 'Enter a workspace name' : 'Enter an invitation code'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              ),
            );
          }
        },
        onCancel: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.primaryBlue, Color(0xFF7C82F8)],
              ).createShader(bounds),
              child: const Text(
                'Koinos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Text(
              '~Work Smarter Together~',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).hintColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.gradientPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
              image: user?.photoURL != null
                  ? DecorationImage(
                      image: NetworkImage(user!.photoURL!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user?.photoURL == null
                ? Center(
                    child: Text(
                      user?.displayName?.isNotEmpty == true
                          ? user!.displayName![0].toUpperCase()
                          : user?.email?[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: BlocConsumer<GroupCubit, GroupState>(
        listener: (context, state) {
          if (state is GroupFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              ),
            );
          }
          if (state is GroupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GroupLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: 2.5,
              ),
            );
          }

          if (state is GroupLoaded && state.groups.isNotEmpty) {
            return _GroupsList(
              groups: state.groups,
              currentUserId: user?.uid ?? '',
            );
          }

          return const _EmptyState();
        },
      ),
      floatingActionButton: _GradientFab(onTap: _showOptionsBottomSheet),
    );
  }
}

class _GroupsList extends StatelessWidget {
  final List<GroupModel> groups;
  final String currentUserId;
  const _GroupsList({required this.groups, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
          child: Row(
            children: [
              Text(
                'Your Workspaces',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${groups.length}',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final color = AppColors.workspaceColors[index % AppColors.workspaceColors.length];
              return WorkspaceCard(
                group: group,
                cardColor: color,
                currentUserId: currentUserId,
                isDarkMode: isDark,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspaces_outline,
              size: 52,
              color: AppColors.primaryBlue.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No workspaces yet',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create or join a workspace\nto start collaborating',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _GradientFab extends StatelessWidget {
  final VoidCallback onTap;
  const _GradientFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, Color(0xFF7C82F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Create / Join',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionsSheet extends StatelessWidget {
  final VoidCallback onCreateTap;
  final VoidCallback onJoinTap;
  const _OptionsSheet({required this.onCreateTap, required this.onJoinTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomSheetTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Add Workspace',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Start fresh or join an existing one',
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),
          _SheetOption(
            icon: Icons.add_circle_outline_rounded,
            iconColor: AppColors.gradientCyan,
            title: 'Create Workspace',
            subtitle: 'Start a new workspace for your team',
            onTap: onCreateTap,
          ),
          const SizedBox(height: 10),
          _SheetOption(
            icon: Icons.group_add_outlined,
            iconColor: AppColors.gradientOrange,
            title: 'Join Workspace',
            subtitle: 'Enter an invitation code to join',
            onTap: onJoinTap,
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SheetOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Theme.of(context).hintColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class _GroupDialog extends StatelessWidget {
  final bool isCreate;
  final TextEditingController controller;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _GroupDialog({
    required this.isCreate,
    required this.controller,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isCreate ? AppColors.gradientCyan : AppColors.gradientOrange;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).dialogTheme.backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCreate ? Icons.add_circle_outline_rounded : Icons.group_add_outlined,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isCreate ? 'Create Workspace' : 'Join Workspace',
                  style: TextStyle(
                    color: Theme.of(context).dialogTheme.titleTextStyle?.color,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08)),
              ),
              child: TextField(
                controller: controller,
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: isCreate ? 'Workspace name...' : 'Invitation code...',
                  hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon: Icon(
                    isCreate ? Icons.edit_rounded : Icons.key_rounded,
                    color: accentColor.withOpacity(0.7),
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08)),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(
                          isCreate ? 'Create' : 'Join',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}