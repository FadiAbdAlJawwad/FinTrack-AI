import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/wallets/presentation/screens/wallets_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

StatefulShellRoute buildMainShellRoute({
  Widget Function(BuildContext, GoRouterState)? homeBuilder,
}) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return MainShellScreen(navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.homeScreen,
            name: AppRoutes.homeScreenName,
            builder: homeBuilder ?? (context, state) => const HomeScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.analyticsScreen,
            name: AppRoutes.analyticsScreenName,
            builder: (context, state) => const AnalyticsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.walletsScreen,
            name: AppRoutes.walletsScreenName,
            builder: (context, state) => const WalletsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.settingsScreen,
            name: AppRoutes.settingsScreenName,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
