// ignore_for_file: deprecated_member_use

import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/core/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("App Info", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withOpacity(0.1),
                ),
                child: const Icon(Icons.workspace_premium, size: 80, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 24),
              Text(
                "Koinos Workspace",
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              const Text(
                "Version 1.0.0",
                style: TextStyle(color: AppColors.textMuted, fontSize: 16),
              ),
              const SizedBox(height: 32),
              Text(
                "A powerful and clean workspace manager designed to help teams organize, collaborate, and achieve their goals efficiently.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}