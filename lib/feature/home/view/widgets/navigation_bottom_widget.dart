// ignore_for_file: deprecated_member_use

import 'package:Koinos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class NavigationBottomWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavigationBottomWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _icons = [
    Icons.home_rounded,
    Icons.task_alt,
    Icons.forum_rounded,
    Icons.tune_rounded,
  ];

  static const _labels = ['Home', 'Tasks', 'Chat', 'Settings'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2438) : Colors.white,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.primaryBlue.withOpacity(0.18)
                : Colors.black.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_icons.length, (index) {
          final isActive = currentIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [AppColors.primaryBlue, Color(0xFF7C82F8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icons[index],
                      color: isActive ? Colors.white : AppColors.textMuted,
                      size: 22,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOutCubic,
                      child: isActive
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _labels[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
