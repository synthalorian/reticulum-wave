import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

/// Persistent scaffold with bottom navigation that wraps all main screens.
/// Uses StatefulShellRoute from GoRouter to keep state across tabs.
class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        backgroundColor: AppColors.deepPurple,
        indicatorColor: AppColors.electricPurple.withValues(alpha: 0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.message_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.message, color: AppColors.neonYellow),
            label: 'Messages',
            tooltip: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.hub_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.hub, color: AppColors.neonYellow),
            label: 'Network',
            tooltip: 'Network',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.map, color: AppColors.neonYellow),
            label: 'Map',
            tooltip: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.radio, color: AppColors.neonYellow),
            label: 'RNode',
            tooltip: 'RNode',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            selectedIcon: Icon(Icons.settings, color: AppColors.neonYellow),
            label: 'Settings',
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
}
