import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/groups/groups_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/subscriptions/detail/subscription_detail_screen.dart';
import '../features/subscriptions/edit/subscription_form_screen.dart';
import '../features/subscriptions/list/subscriptions_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
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
              path: '/subscriptions',
              builder: (context, state) => const SubscriptionsListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen(),
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
    GoRoute(
      path: '/subscriptions/new',
      builder: (context, state) => const SubscriptionFormScreen(),
    ),
    GoRoute(
      path: '/subscriptions/:id/edit',
      builder: (context, state) =>
          SubscriptionFormScreen(subscriptionId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/subscriptions/:id',
      builder: (context, state) =>
          SubscriptionDetailScreen(subscriptionId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/groups', builder: (context, state) => const GroupsScreen()),
  ],
);
