// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF5C62F2);

  static const Color gradientPink = Color(0xFFDC6691);
  static const Color gradientCyan = Color(0xFF06B6D4);
  static const Color gradientOrange = Color(0xFFF97316);
  static const Color gradientGreen = Color(0xFF10B981);
  static const Color gradientPurple = Color(0xFF7B2CBF);

  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color darkBackground = Color(0xFF0F172A);

  static const Color textLightMode = Color(0xFF1E293B);
  static const Color textDarkMode = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);

  static Color glassBackgroundLight = Colors.black.withOpacity(0.1);
  static Color glassBackgroundDark = Colors.black.withOpacity(0.25);
  static Color glassBorderLight = Colors.white.withOpacity(0.15);
  static Color glassBorder = Colors.white.withOpacity(0.4);

  static const Color taskTodo = Color(0xFFF59E0B);
  static const Color taskInProgress = Color(0xFF3B82F6);
  static const Color taskDone = Color(0xFF10B981);

  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  static const List<Color> workspaceColors = [
    gradientPink,
    gradientCyan,
    gradientOrange,
    gradientGreen,
    gradientPurple,
  ];
}
