// ignore_for_file: deprecated_member_use

import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/feature/auth/viewmodel/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordDialog extends StatefulWidget {
  const ResetPasswordDialog({super.key});

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<AuthCubit>();

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Reset Password',
        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter your email address to receive a password reset link.',
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: 'Email',
              hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: () {
            final email = _emailController.text.trim();
            if (email.isNotEmpty && RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
              FocusScope.of(context).unfocus();
              cubit.resetPassword(email: email);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid email address'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: const Text('Send Link', style: TextStyle(color: AppColors.lightBackground, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}