import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/account/account_screen.dart';
import '../features/analytics/analytics_screen.dart';
import '../features/sessions/sessions_screen.dart';
import '../features/timer/timer_screen.dart';

import 'main_scaffold.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> timerNavigatorKey =
GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> sessionsNavigatorKey =
GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> analyticsNavigatorKey =
GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> accountNavigatorKey =
GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,

  initialLocation: '/',

  routes: [

    StatefulShellRoute.indexedStack(

      builder: (context, state, navigationShell) {
        return MainScaffold(
          navigationShell: navigationShell,
        );
      },

      branches: [

        StatefulShellBranch(
          navigatorKey: timerNavigatorKey,

          routes: [

            GoRoute(
              path: '/',
              pageBuilder: (context, state) {
                return const NoTransitionPage(
                  child: TimerScreen(),
                );
              },
            ),
          ],
        ),

        StatefulShellBranch(
          navigatorKey: sessionsNavigatorKey,

          routes: [

            GoRoute(
              path: '/sessions',
              pageBuilder: (context, state) {
                return const NoTransitionPage(
                  child: SessionsScreen(),
                );
              },
            ),
          ],
        ),

        StatefulShellBranch(
          navigatorKey: analyticsNavigatorKey,

          routes: [

            GoRoute(
              path: '/analytics',
              pageBuilder: (context, state) {
                return const NoTransitionPage(
                  child: AnalyticsScreen(),
                );
              },
            ),
          ],
        ),

        StatefulShellBranch(
          navigatorKey: accountNavigatorKey,

          routes: [

            GoRoute(
              path: '/account',
              pageBuilder: (context, state) {
                return const NoTransitionPage(
                  child: AccountScreen(),
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);