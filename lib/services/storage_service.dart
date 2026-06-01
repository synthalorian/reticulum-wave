import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

/// Local storage service using Hive for offline-first data persistence.
/// Handles identities, conversations, messages, and app settings.
class StorageService {
  static const String _identitiesBox = 'identities';
  static const String _conversationsBox = 'conversations';
  static const String _settingsBox = 'settings';

  Box<Map>? _identities;
  Box<Map>? _conversations;
  Box<dynamic>? _settings;

  bool _initialized = false;

  /// Initialize Hive and open all boxes.
  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    _identities = await Hive.openBox<Map>(_identitiesBox);
    _conversations = await Hive.openBox<Map>(_conversationsBox);
    _settings = await Hive.openBox<dynamic>(_settingsBox);

    _initialized = true;
  }

  // ─── Identities ───

  Future<void> saveIdentity(ReticulumIdentity identity) async {
    await _ensureInit();
    await _identities!.put(identity.hash, identity.toJson());
  }

  ReticulumIdentity? getIdentity(String hash) {
    _ensureInitSync();
    final data = _identities!.get(hash);
    if (data == null) return null;
    return ReticulumIdentity.fromJson(Map<String, dynamic>.from(data));
  }

  List<ReticulumIdentity> getAllIdentities() {
    _ensureInitSync();
    return _identities!.values
        .map((data) => ReticulumIdentity.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  Future<void> deleteIdentity(String hash) async {
    await _ensureInit();
    await _identities!.delete(hash);
  }

  // ─── Conversations ───

  Future<void> saveConversation(Conversation conversation) async {
    await _ensureInit();
    await _conversations!.put(conversation.id, conversation.toJson());
  }

  Conversation? getConversation(String id) {
    _ensureInitSync();
    final data = _conversations!.get(id);
    if (data == null) return null;
    return Conversation.fromJson(Map<String, dynamic>.from(data));
  }

  List<Conversation> getAllConversations() {
    _ensureInitSync();
    return _conversations!.values
        .map((data) => Conversation.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  Future<void> deleteConversation(String id) async {
    await _ensureInit();
    await _conversations!.delete(id);
  }

  // ─── Settings ───

  Future<void> setSetting(String key, dynamic value) async {
    await _ensureInit();
    await _settings!.put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    _ensureInitSync();
    final value = _settings!.get(key);
    return value != null ? value as T : defaultValue;
  }

  Future<void> deleteSetting(String key) async {
    await _ensureInit();
    await _settings!.delete(key);
  }

  // ─── Helpers ───

  Future<void> _ensureInit() async {
    if (!_initialized) await initialize();
  }

  void _ensureInitSync() {
    if (!_initialized) {
      throw StateError('StorageService not initialized. Call initialize() first.');
    }
  }

  /// Wipe all data — useful for logout / reset.
  Future<void> clearAll() async {
    await _ensureInit();
    await _identities!.clear();
    await _conversations!.clear();
    await _settings!.clear();
  }
}

/// Global singleton instance.
final storageService = StorageService();
