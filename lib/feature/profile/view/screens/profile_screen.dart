// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:Koinos/core/settings/cubit/settings_cubit.dart';
import 'package:Koinos/core/settings/cubit/settings_state.dart';
import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/core/widgets/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final _auth = FirebaseAuth.instance;
    final settingsState = context.watch<SettingsCubit>().state;
    
    final theme = Theme.of(context);

    final cubitUserName = settingsState.userName;
    final String displayUserName = (cubitUserName == "User" ||
            cubitUserName.isEmpty ||
            cubitUserName == "null")
        ? (_auth.currentUser?.displayName ?? "User")
        : cubitUserName;

    final isLoadingImage = settingsState.status == SettingsStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primaryBlue,
                  backgroundImage: NetworkImage(_auth.currentUser?.photoURL ?? ""),
                  child: _auth.currentUser!.photoURL!.isEmpty
                      ? Text(
                          displayUserName.isNotEmpty ? displayUserName.substring(0, 1).toUpperCase() : "U",
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : null,
                ),
                
                if (isLoadingImage)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.lightBackground),
                      ),
                    ),
                  ),

                if (!isLoadingImage)
                  GestureDetector(
                    onTap: () {
                      context.read<SettingsCubit>().uploadProfileImage();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.glassBackgroundDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppColors.lightBackground,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: theme.colorScheme.surface,
              clipBehavior: Clip.antiAlias,
              shadowColor: AppColors.primaryBlue,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person,
                          color: AppColors.gradientCyan),
                      title: const Text("Username"),
                      subtitle: Text(displayUserName,
                          style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 22)),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit,
                            color: AppColors.gradientCyan),
                        onPressed: () {
                          final TextEditingController _nameController =
                              TextEditingController(text: displayUserName);

                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Edit Name"),
                                  content: TextField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      hintText: "Enter new name",
                                      hintStyle: TextStyle(
                                          color: theme
                                              .textTheme.bodyMedium?.color),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        if (_nameController.text.isNotEmpty) {
                                          await context
                                              .read<SettingsCubit>()
                                              .updateUserName(
                                                  _nameController.text);
                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "Please enter a valid name")),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: AppColors.primaryBlue,
                                        ),
                                        child: const Text("Save"),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email,
                          color: AppColors.gradientPink),
                      title: const Text("Email"),
                      subtitle: Text(user?.email ?? "No Email",
                          style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                              fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}