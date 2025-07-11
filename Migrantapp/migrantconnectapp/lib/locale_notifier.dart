// lib/locale_notifier.dart
import 'package:flutter/material.dart';

class LocaleNotifier extends ChangeNotifier {
  Locale _currentLocale = const Locale('en'); // Default to English

  Locale get currentLocale => _currentLocale;

  void setLocale(Locale newLocale) {
    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;
      notifyListeners(); // Notify listeners that the locale has changed
    }
  }
}