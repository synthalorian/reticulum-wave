import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// App settings state.
class AppSettings {
  final bool darkMode;
  final bool notificationsEnabled;
  final bool vibrateEnabled;
  final double fontScale;
  final String? activeTheme;

  const AppSettings({
    this.darkMode = true,
    this.notificationsEnabled = true,
    this.vibrateEnabled = true,
    this.fontScale = 1.0,
    this.activeTheme,
  });

  AppSettings copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    bool? vibrateEnabled,
    double? fontScale,
    String? activeTheme,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      vibrateEnabled: vibrateEnabled ?? this.vibrateEnabled,
      fontScale: fontScale ?? this.fontScale,
      activeTheme: activeTheme ?? this.activeTheme,
    );
  }

  Map<String, dynamic> toJson() => {
    'darkMode': darkMode,
    'notificationsEnabled': notificationsEnabled,
    'vibrateEnabled': vibrateEnabled,
    'fontScale': fontScale,
    'activeTheme': activeTheme,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    darkMode: json['darkMode'] ?? true,
    notificationsEnabled: json['notificationsEnabled'] ?? true,
    vibrateEnabled: json['vibrateEnabled'] ?? true,
    fontScale: (json['fontScale'] ?? 1.0).toDouble(),
    activeTheme: json['activeTheme'],
  );
}

/// Settings notifier with Hive persistence.
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  static const String _settingsKey = 'app_settings';

  void _load() {
    final json = storageService.getSetting<Map>(_settingsKey);
    if (json != null) {
      state = AppSettings.fromJson(Map<String, dynamic>.from(json));
    }
  }

  Future<void> _save() async {
    await storageService.setSetting(_settingsKey, state.toJson());
  }

  void setDarkMode(bool value) {
    state = state.copyWith(darkMode: value);
    _save();
  }

  void setNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
    _save();
  }

  void setVibrate(bool value) {
    state = state.copyWith(vibrateEnabled: value);
    _save();
  }

  void setFontScale(double value) {
    state = state.copyWith(fontScale: value.clamp(0.8, 1.5));
    _save();
  }

  void setTheme(String? theme) {
    state = state.copyWith(activeTheme: theme);
    _save();
  }
}

/// Provider for app settings.
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
