import 'package:go_router/go_router.dart';
import 'screens/conversations_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/network_screen.dart';
import 'screens/map_screen.dart';
import 'screens/identity_screen.dart';
import 'screens/rnode_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/scaffold_with_nav.dart';

/// Route paths for the app.
class Routes {
  Routes._();

  static const String conversations = '/';
  static const String chat = '/chat/:id';
  static const String network = '/network';
  static const String map = '/map';
  static const String rnode = '/rnode';
  static const String settings = '/settings';
}

/// GoRouter configuration with a persistent bottom navigation shell.
final router = GoRouter(
  initialLocation: Routes.conversations,
  debugLogDiagnostics: true,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNav(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.conversations,
              builder: (context, state) => const ConversationsScreen(),
              routes: [
                GoRoute(
                  path: 'chat/:id',
                  builder: (context, state) => ChatScreen(
                    conversationId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.network,
              builder: (context, state) => const NetworkScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.map,
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.rnode,
              builder: (context, state) => const RNodeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settings,
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'identity',
                  builder: (context, state) => const IdentityScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
