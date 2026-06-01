import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme.dart';

/// Settings tab — identity, appearance, notifications, data management.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = ref.watch(identityProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Identity Section
          const _SectionHeader(title: 'Identity'),
          _IdentityCard(identity: identity),
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.electricPurple),
            title: const Text('Manage Identity'),
            subtitle: const Text('Create, import, or export'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () => context.push('/identity'),
          ),

          const Divider(),

          // Appearance Section
          const _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: AppColors.hotPink),
            title: const Text('Dark Mode'),
            subtitle: const Text('Synthwave Dark (default)'),
            value: settings.darkMode,
            onChanged: (v) => ref.read(settingsProvider.notifier).setDarkMode(v),
          ),
          ListTile(
            leading: const Icon(Icons.format_size, color: AppColors.hotPink),
            title: const Text('Font Size'),
            subtitle: Text('${(settings.fontScale * 100).toInt()}%'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () => _showFontScaleDialog(context, ref, settings.fontScale),
          ),

          const Divider(),

          // Notifications Section
          const _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: AppColors.neonYellow),
            title: const Text('Message Notifications'),
            subtitle: const Text('Show alerts for new messages'),
            value: settings.notificationsEnabled,
            onChanged: (v) => ref.read(settingsProvider.notifier).setNotifications(v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration, color: AppColors.neonYellow),
            title: const Text('Vibrate'),
            subtitle: const Text('Haptic feedback on message receive'),
            value: settings.vibrateEnabled,
            onChanged: (v) => ref.read(settingsProvider.notifier).setVibrate(v),
          ),

          const Divider(),

          // Network Section
          const _SectionHeader(title: 'Network'),
          const ListTile(
            leading: Icon(Icons.router, color: AppColors.cyan),
            title: Text('Propagation Nodes'),
            subtitle: Text('Configure message propagation'),
          ),
          const ListTile(
            leading: Icon(Icons.usb, color: AppColors.cyan),
            title: Text('RNode Configuration'),
            subtitle: Text('USB / Bluetooth radio settings'),
          ),
          const ListTile(
            leading: Icon(Icons.wifi_tethering, color: AppColors.cyan),
            title: Text('Interfaces'),
            subtitle: Text('Active: Auto'),
          ),

          const Divider(),

          // Data Section
          const _SectionHeader(title: 'Data'),
          const ListTile(
            leading: Icon(Icons.download_for_offline, color: AppColors.online),
            title: Text('Offline Maps'),
            subtitle: Text('Download map tiles for offline use'),
          ),
          const ListTile(
            leading: Icon(Icons.backup, color: AppColors.online),
            title: Text('Export Conversations'),
            subtitle: Text('Save message history to file'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.offline),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all messages and settings'),
            onTap: () => _showClearDataDialog(context, ref),
          ),

          const Divider(),

          // About Section
          const _SectionHeader(title: 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline, color: AppColors.textSecondary),
            title: Text('Version'),
            subtitle: Text('0.1.0 (alpha)'),
          ),
          const ListTile(
            leading: Icon(Icons.code, color: AppColors.textSecondary),
            title: Text('Source Code'),
            subtitle: Text('github.com/synthalorian/reticulum-wave'),
          ),
          const ListTile(
            leading: Icon(Icons.gavel, color: AppColors.textSecondary),
            title: Text('License'),
            subtitle: Text('Apache 2.0'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showFontScaleDialog(BuildContext context, WidgetRef ref, double current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Font Size', style: TextStyle(color: AppColors.textPrimary)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Preview Text',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16 * current,
                  ),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: current,
                  min: 0.8,
                  max: 1.5,
                  divisions: 7,
                  label: '${(current * 100).toInt()}%',
                  onChanged: (v) {
                    setState(() => current = v);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).setFontScale(current);
              Navigator.pop(context);
            },
            child: const Text('Apply', style: TextStyle(color: AppColors.electricPurple)),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear All Data?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will permanently delete all conversations, messages, and settings. This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(conversationsProvider.notifier).clearAll();
              ref.read(peersProvider.notifier).clearAll();
              ref.read(identityProvider.notifier).clearIdentity();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.offline)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({this.identity});

  final dynamic identity;

  @override
  Widget build(BuildContext context) {
    if (identity == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.divider,
              child: Icon(Icons.person_off, color: AppColors.textSecondary),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Active Identity',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Create or import an identity to start messaging',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.electricPurple.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.electricPurple.withValues(alpha: 0.2),
            child: const Icon(Icons.person, color: AppColors.electricPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  identity.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (identity.displayName != null)
                  Text(
                    '@${identity.displayName}',
                    style: const TextStyle(color: AppColors.hotPink, fontSize: 13),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Hash: ${identity.hash.substring(0, 16)}...',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified, color: AppColors.online, size: 20),
        ],
      ),
    );
  }
}
