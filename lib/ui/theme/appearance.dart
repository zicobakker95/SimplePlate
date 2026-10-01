import 'package:flutter/material.dart';

import '../../services/storage_service.dart';

/// Light / dark / follow-the-system, persisted. Defaults to the system
/// setting (the app used to be dark-only).
class AppearanceController extends ValueNotifier<ThemeMode> {
  AppearanceController(this._storage) : super(_parse(_storage.themeMode));

  final StorageService _storage;

  static ThemeMode _parse(String? raw) => switch (raw) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> set(ThemeMode mode) async {
    value = mode;
    await _storage.setThemeMode(mode.name);
  }
}
