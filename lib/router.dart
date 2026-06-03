import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'models/peer.dart';
import 'screens/conversations_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/compose_screen.dart';
import 'screens/peer_detail_screen.dart';
import 'screens/network_screen.dart';
import 'screens/map_screen.dart';
import 'screens/identity_screen.dart';
import 'screens/rnode_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/search_screen.dart';
import 'widgets/scaffold_with_nav.dart';

/// Route paths for the app.
class Routes {
  Routes._();

  static const String conversations = '/';
  static const String chat = '/chat/:id';
  static const String compose = '/compose';
  static const String search = '/search';
  static const String peerDetail = '/peer/:hash';
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
            GoRoute(
              path: 'compose',
              builder: (context, state) => ComposeScreen(
                prefilledContent: state.extra as String?,
              ),
            ),
            GoRoute(
              path: 'search',
              builder: (context, state) => const SearchScreen(),
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
              routes: [
                GoRoute(
                  path: 'peer/:hash',
                  builder: (context, state) {
                    final peer = state.extra as Peer?;
                    if (peer == null) {
                      return const Scaffold(
                        body: Center(child: Text('Peer not found')),
                      );
                    }
                    return PeerDetailScreen(peer: peer);
                  },
                ),
              ],
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
