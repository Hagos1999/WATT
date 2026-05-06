import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/providers/auth_providers.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/history/history_screen.dart';
import '../features/settings/settings_screen.dart';
import '../core/constants/app_colors.dart';

/// Named route paths.
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String settings = '/settings';
}

/// Bottom navigation shell for main screens.
class MainShell extends StatelessWidget {
  final int currentIndex;
  final Widget child;

  const MainShell({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go(AppRoutes.dashboard);
                break;
              case 1:
                context.go(AppRoutes.history);
                break;
              case 2:
                context.go(AppRoutes.settings);
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

/// The GoRouter configuration provider.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // Login screen
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      // Main tabs with bottom nav
      ShellRoute(
        builder: (context, state, child) {
          int index = 0;
          final location = state.uri.path;
          if (location.startsWith(AppRoutes.history)) {
            index = 1;
          } else if (location.startsWith(AppRoutes.settings)) {
            index = 2;
          }
          return MainShell(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn =
          ref.read(authRepositoryProvider).isAuthenticated;
      final isOnSplash = state.uri.path == AppRoutes.splash;
      final isOnLogin = state.uri.path == AppRoutes.login;

      // Allow splash screen to handle its own navigation
      if (isOnSplash) return null;

      // Not logged in → go to login
      if (!isLoggedIn) {
        if (isOnLogin) return null;
        return AppRoutes.login;
      }

      // Logged in but on login page → go to dashboard
      if (isOnLogin) return AppRoutes.dashboard;

      return null;
    },
  );
});
