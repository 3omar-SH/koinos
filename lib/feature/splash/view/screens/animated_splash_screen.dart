import 'package:Koinos/core/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Koinos/core/theme/app_colors.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  void _startApp() async {
    FlutterNativeSplash.remove();

    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.go(RouteNames.home);
      } else {
        context.go(RouteNames.auth);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/koinos.png',
              width: 150,
              height: 150,
            )
                .animate(delay: 200.ms)
                .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                  duration: 1200.ms,
                ) 
                .fadeIn(duration: 600.ms),

            const SizedBox(height: 20),

            const Text(
              "Koinos",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkMode,
                letterSpacing: 2,
              ),
            )
                .animate(delay: 600.ms)
                .fadeIn(delay: 800.ms)
                .slideY(begin: 0.5, end: 0 , curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}