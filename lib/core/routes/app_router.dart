import 'package:Koinos/core/routes/route_names.dart';
import 'package:Koinos/feature/auth/view/screens/auth_screen.dart';
import 'package:Koinos/feature/groups/view/screens/groups_hub_screen.dart';
import 'package:Koinos/feature/home/view/screens/dashboard_screen.dart';
import 'package:Koinos/feature/info/view/screens/info_screen.dart';
import 'package:Koinos/feature/profile/view/screens/profile_screen.dart';
import 'package:Koinos/feature/splash/view/screens/animated_splash_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const AnimatedSplashScreen(),
      ),
      GoRoute(
        path: RouteNames.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const GroupsHubScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.info,
        builder: (context, state) => const InfoScreen(),
      ),
      GoRoute(
        path: RouteNames.workspace,
        builder: (context, state){
          final workspaceId = state.pathParameters['id'] ?? '';
          return DashboardScreen(workspaceId: workspaceId);
        }
      ),
    ],
  );
}
