import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// Holds the current active identity and all known identities.
class IdentityNotifier extends StateNotifier<ReticulumIdentity?> {
  IdentityNotifier() : super(null);

  void setIdentity(ReticulumIdentity identity) {
    state = identity;
  }

  void clearIdentity() {
    state = null;
  }

  /// Create a new identity (placeholder — will integrate with crypto later).
  void createIdentity(String name) {
    final now = DateTime.now();
    final identity = ReticulumIdentity(
      name: name,
      hash: 'placeholder_${now.millisecondsSinceEpoch}',
      publicKey: 'placeholder_key',
      createdAt: now,
      isActive: true,
    );
    state = identity;
  }
}

/// Provider for the active identity.
final identityProvider =
    StateNotifierProvider<IdentityNotifier, ReticulumIdentity?>((ref) {
  return IdentityNotifier();
});
