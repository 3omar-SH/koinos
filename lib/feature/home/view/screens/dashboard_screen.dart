import 'package:Koinos/core/widgets/app_drawer.dart';
import 'package:Koinos/feature/chat/view/screens/chat_screen.dart';
import 'package:Koinos/feature/settings/view/screens/settings_screen.dart';
import 'package:Koinos/feature/task/view/screens/task_screen.dart';
import 'package:Koinos/feature/home/view/widgets/build_top_banner_card.dart';
import 'package:Koinos/feature/home/view/widgets/metrics_widget.dart';
import 'package:Koinos/feature/home/view/widgets/navigation_bottom_widget.dart';
import 'package:Koinos/feature/home/view/widgets/recent_tasks_widget.dart';
import 'package:Koinos/feature/home/view/widgets/sprint_card_widget.dart';
import 'package:Koinos/feature/home/view/widgets/team_members_widget.dart';
import 'package:Koinos/feature/home/viewmodel/dashboard_cubit.dart';
import 'package:Koinos/feature/home/viewmodel/dashboard_state.dart';
import 'package:Koinos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatefulWidget {
  final String workspaceId;
  const DashboardScreen({super.key, required this.workspaceId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentBottomIndex = 0;

  final Set<int> _visitedTabs = {0};

  static const _labels = ['Home', 'Tasks', 'Chat', 'Settings'];

  void _onTabTapped(int index) {
    setState(() {
      _currentBottomIndex = index;
      _visitedTabs.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => DashboardCubit()..initDashboard(widget.workspaceId),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        extendBody: true,
        appBar: _buildAppBar(context),
        drawer: const AppDrawer(),
        body: Stack(
          children: [
            IndexedStack(
              index: _currentBottomIndex,
              children: [
                _buildDashboardContent(context),
                _visitedTabs.contains(1)
                    ? TasksScreen(workspaceId: widget.workspaceId)
                    : const SizedBox.shrink(),
                _visitedTabs.contains(2)
                    ? ChatScreen(workspaceId: widget.workspaceId)
                    : const SizedBox.shrink(),
                _visitedTabs.contains(3)
                    ? SettingsScreen(workspaceId: widget.workspaceId)
                    : const SizedBox.shrink(),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: NavigationBottomWidget(
                currentIndex: _currentBottomIndex,
                onTap: _onTabTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      // leading: Builder(
      //   builder: (ctx) => IconButton(
      //     icon: Icon(Icons.menu_rounded, color: theme.textTheme.bodyLarge?.color),
      //     onPressed: () => Scaffold.of(ctx).openDrawer(),
      //   ),
      // ),
      title: Text(
        _labels[_currentBottomIndex],
        style: TextStyle(
          color: theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.notifications_none_rounded, color: theme.textTheme.bodyLarge?.color),
              onPressed: () {},
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.gradientPink,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listener: (context, state) {
        if (state is DashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }
        if (state is DashboardLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BuildTopBannerCard(title: state.workspaceName),
                const SizedBox(height: 20),
                TeamMembersWidget(members: state.teamMembers),
                const SizedBox(height: 24),
                MetricsWidget(
                  total: state.totalTasks,
                  inProgress: state.inProgressTasks,
                  done: state.doneTasks,
                ),
                const SizedBox(height: 24),
                SprintCardWidget(
                  progress: state.sprintProgress,
                  todo: state.todoTasks,
                  inProgress: state.inProgressTasks,
                  done: state.doneTasks,
                ),
                const SizedBox(height: 24),
                RecentTasksWidget(tasks: state.tasks),
              ],
            ),
          );
        }
        if (state is DashboardError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
