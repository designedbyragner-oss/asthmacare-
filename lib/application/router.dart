/// التوجيه — go_router مع هيكل تنقل سفلي بأربعة فروع (§10).
library;

import 'package:go_router/go_router.dart';

import 'package:asthma_care/presentation/alerts/alerts_screen.dart';
import 'package:asthma_care/presentation/auth/login_screen.dart';
import 'package:asthma_care/presentation/auth/splash_screen.dart';
import 'package:asthma_care/presentation/baseline/baseline_screen.dart';
import 'package:asthma_care/presentation/environment/environment_screen.dart';
import 'package:asthma_care/presentation/home/home_screen.dart';
import 'package:asthma_care/presentation/main_shell.dart';
import 'package:asthma_care/presentation/medical_log/medical_log_screen.dart';
import 'package:asthma_care/presentation/monitoring/monitoring_screen.dart';
import 'package:asthma_care/presentation/onboarding/pairing_screen.dart';
import 'package:asthma_care/presentation/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const PairingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/alerts',
      builder: (context, state) => const AlertsScreen(),
    ),
    GoRoute(
      path: '/monitoring',
      builder: (context, state) => const MonitoringScreen(),
    ),
    GoRoute(
      path: '/baseline',
      builder: (context, state) => const BaselineScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/log',
              builder: (context, state) => const MedicalLogScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/environment',
              builder: (context, state) => const EnvironmentScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
