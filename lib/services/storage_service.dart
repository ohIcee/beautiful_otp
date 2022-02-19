import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {

  static const String _authEntriesOrderKey = 'auth_entries';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print('Initialized Storage');
    }
  }

  static List<String>? getAuthEntries() {
    if (!_checkInitialized()) {
      return null;
    }

    return _prefs!.getStringList(_authEntriesOrderKey);
  }

  static Future<void> setAuthEntries(List<String> order) async {
    if (!_checkInitialized()) {
      return;
    }

    await _prefs!.setStringList(_authEntriesOrderKey, order);
  }

  static bool _checkInitialized() {
    if (_prefs == null) {
      if (kDebugMode) {
        print('Storage not initialized. Please make sure to run StorageProvider.init()');
      }
      return false;
    }
    return true;
  }

}