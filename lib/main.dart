import 'package:Koinos/core/settings/cubit/settings_cubit.dart';
import 'package:Koinos/core/settings/cubit/settings_state.dart';
import 'package:Koinos/core/theme/app_theme.dart';
import 'package:Koinos/feature/chat/viewmodel/chat_cubit.dart';
import 'package:Koinos/feature/groups/viewmodel/group_cubit.dart';
import 'package:Koinos/feature/home/viewmodel/dashboard_cubit.dart';
import 'package:Koinos/feature/task/viewmodel/task_cubit.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Koinos/core/routes/app_router.dart';
import 'package:Koinos/feature/auth/viewmodel/auth_cubit.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/adapters.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await Hive.initFlutter();
  await Hive.openBox('settings');
  
  runApp(const KoinosApp());
}

class KoinosApp extends StatelessWidget {
  const KoinosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(),
        ),
        BlocProvider<GroupCubit>(
          create: (_) => GroupCubit(),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(
            Hive.box('settings'),
          ),
        ),
        BlocProvider<DashboardCubit>(
          create: (_) => DashboardCubit(),
        ),
        BlocProvider<ChatCubit>(
          create: (_) => ChatCubit(),
        ),
        BlocProvider<TaskCubit>(
          create: (_) => TaskCubit(),
        ),
      ],
      child: BlocSelector<SettingsCubit, SettingsState, ThemeMode>(
        selector: (state) => state.themeMode,
        builder: (BuildContext context, ThemeMode themeMode) {
          return MaterialApp.router(
            themeMode: themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
            title: 'Koinos',
            routerConfig: AppRouter.router,
            builder: (context, child) {
              return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: child!);
            },
          );
        },
      ),
    );
  }
}