import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides the current locale to the whole app and persists the user choice.
class LanguageProvider extends ChangeNotifier {
  /// Default language = Swahili (TZ)
  Locale _locale = const Locale('sw');

  Locale get locale => _locale;

  /// Load the saved language from SharedPreferences (or fall back to Swahili).
  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code') ?? 'sw';
    _locale = Locale(code);
    notifyListeners();
  }

  /// Change the language and persist the new value.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }
}