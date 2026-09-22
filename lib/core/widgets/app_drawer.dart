// ignore_for_file: deprecated_member_use

import 'package:Koinos/core/routes/route_names.dart';
import 'package:Koinos/core/settings/cubit/settings_cubit.dart';
import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/feature/auth/viewmodel/auth_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        context.watch<SettingsCubit>().state.themeMode == ThemeMode.dark;

    final _auth = FirebaseAuth.instance;

    final cubitUserName = context.watch<SettingsCubit>().state.userName;
    final String displayUserName = (cubitUserName == "User" ||
            cubitUserName.isEmpty ||
            cubitUserName == "null")
        ? (FirebaseAuth.instance.currentUser?.displayName ?? "User")
        : cubitUserName;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryBlue,
                  backgroundImage:
                      NetworkImage(_auth.currentUser?.photoURL ?? ""),
                  child: _auth.currentUser!.photoURL!.isEmpty
                      ? Text(
                          displayUserName.isNotEmpty
                              ? displayUserName.substring(0, 1).toUpperCase()
                              : "U",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightBackground),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    displayUserName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color:
                  isDarkMode ? AppColors.primaryBlue : AppColors.gradientOrange,
            ),
            title: Text(
              isDarkMode ? "Dark Mode" : "Light Mode",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                context.read<SettingsCubit>().toggleTheme();
              },
              activeColor: AppColors.primaryBlue,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: AppColors.gradientPurple),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
              context.go(RouteNames.home);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_2_outlined,
                color: AppColors.gradientCyan),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.profile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: AppColors.gradientOrange),
            title: const Text("Info"),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteNames.info);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<AuthCubit>().signOut();
                          context.go(RouteNames.auth);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: AppColors.error,
                          ),
                          child: const Text("Logout",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
