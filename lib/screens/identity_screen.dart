import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme.dart';

/// Identity management screen — create, import, export identities.
class IdentityScreen extends ConsumerWidget {
  const IdentityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = ref.watch(identityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (identity != null) ...[
            _IdentityCard(identity: identity),
            const SizedBox(height: 24),
          ],
          _ActionCard(
            icon: Icons.person_add,
            color: AppColors.electricPurple,
            title: 'Create New Identity',
            subtitle: 'Generate a fresh Reticulum identity',
            onTap: () => _showCreateDialog(context, ref),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.download,
            color: AppColors.online,
            title: 'Import Identity',
            subtitle: 'Restore from a backup file',
            onTap: () {
              // TODO: file picker + import
            },
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.upload,
            color: AppColors.hotPink,
            title: 'Export Identity',
            subtitle: 'Save your identity to a file',
            onTap: () {
              // TODO: export to file
            },
          ),
          const SizedBox(height: 12),
          if (identity != null)
            _ActionCard(
              icon: Icons.delete_forever,
              color: AppColors.offline,
              title: 'Delete Identity',
              subtitle: 'Permanently remove this identity',
              onTap: () => _showDeleteDialog(context, ref),
            ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Create Identity', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Display name',
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(identityProvider.notifier).createIdentity(name);
                Navigator.pop(context);
              }
            },
            child: const Text('Create', style: TextStyle(color: AppColors.electricPurple)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Identity?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will permanently delete your identity. You will lose access to any messages sent to this address.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
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

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.identity});

  final ReticulumIdentity identity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.electricPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.electricPurple.withValues(alpha: 0.2),
            child: const Icon(Icons.person, color: AppColors.electricPurple, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            identity.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (identity.displayName != null)
            Text(
              '@${identity.displayName}',
              style: const TextStyle(color: AppColors.hotPink, fontSize: 16),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.deepPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              identity.hash,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
