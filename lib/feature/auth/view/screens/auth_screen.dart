// ignore_for_file: unnecessary_const, deprecated_member_use

import 'dart:ui';
import 'package:Koinos/feature/auth/view/widgets/reset_dialog_widget.dart';
import 'package:Koinos/feature/auth/view/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/feature/auth/viewmodel/auth_cubit.dart';
import 'package:Koinos/feature/auth/viewmodel/auth_state.dart';

class _AuthValidators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Please enter an email';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a username';
    if (value.length < 3) return 'Username must be at least 3 characters';
    return null;
  }

  static String? Function(String?) confirmPassword(
          TextEditingController passwordCtrl) =>
      (value) {
        if (value == null || value.isEmpty)
          return 'Please confirm your password';
        if (value != passwordCtrl.text) return 'Passwords do not match';
        return null;
      };
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _emailController.clear();
      _usernameController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _formKey.currentState?.reset();
    });
  }

  void _showResetPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const ResetPasswordDialog(), 
    );
  }

  void _handleSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      if (_isLogin) {
        context.read<AuthCubit>().signIn(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      } else {
        context.read<AuthCubit>().signUp(
              username: _usernameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/bg.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.glassBackgroundLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.glassBorderLight,
                          width: 1.5,
                        ),
                      ),
                      child: BlocConsumer<AuthCubit, AuthState>(
                        listener: (context, state) {
                          if (state is AuthSuccess) {
                            context.go('/home');
                          }
                          if (state is AuthFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.errorMessage),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text(
                                    _isLogin ? 'Welcome back' : 'Sign Up',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDarkMode,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _isLogin
                                        ? 'Login to continue to Koinos'
                                        : 'Create an account',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (!_isLogin) ...[
                                  TextFieldWidget(
                                    controller: _usernameController,
                                    hint: 'Username',
                                    icon: Icons.person_outline,
                                    validator: _AuthValidators.username,
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                TextFieldWidget(
                                  controller: _emailController,
                                  hint: 'Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _AuthValidators.email,
                                ),
                                const SizedBox(height: 8),
                                TextFieldWidget(
                                  controller: _passwordController,
                                  hint: 'Password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  validator: _AuthValidators.password,
                                ),
                                if (!_isLogin) ...[
                                  const SizedBox(height: 8),
                                  TextFieldWidget(
                                    controller: _confirmPasswordController,
                                    hint: 'Confirm Password',
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    validator: _AuthValidators.confirmPassword(
                                        _passwordController),
                                  ),
                                ],
                                if (_isLogin)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : () =>
                                              _showResetPasswordDialog(context),
                                      child: const Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                            color: AppColors.textDarkMode),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () => _handleSubmit(context),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: AppColors.textDarkMode,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            _isLogin ? 'Sign In' : 'Sign Up',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: AppColors.textDarkMode,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(
                                        color: AppColors.textMuted,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Text(
                                        "OR",
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(
                                        color: AppColors.textMuted,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.glassBackgroundDark,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            FocusScope.of(context).unfocus();
                                            context.read<AuthCubit>().signInWithGoogle();
                                          },
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: AppColors.primaryBlue, 
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/images/google.png',
                                                width: 24,
                                                height: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                "Continue with Google",
                                                style: TextStyle(
                                                  color: AppColors.textDarkMode,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isLogin
                                          ? "Don't have an account?"
                                          : 'Already have an account!',
                                      style: const TextStyle(
                                          color: AppColors.textDarkMode),
                                    ),
                                    TextButton(
                                      onPressed: isLoading ? null : _toggleMode,
                                      child: Text(
                                        _isLogin ? 'Sign Up' : 'Sign In',
                                        style: const TextStyle(
                                            color: AppColors.primaryBlue , fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ]
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}