import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _authEntriesOrderKey = 'auth_entries';
  static const String _biometricTypeOrderKey = 'biometric_type';
  static const String _biometricEnabled = 'biometric_enabled';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print('Initialized Storage');
    }
  }

  static Future<void> setBiometricEnabled(bool? enabled) async {
    if (!_checkInitialized()) {
      return;
    }

    if (enabled == null) {
      await _prefs!.remove(_biometricEnabled);
    } else {
      await _prefs!.setBool(_biometricEnabled, enabled);
    }
  }

  static Future<bool?> getBiometricEnabled() async {
    if (!_checkInitialized()) {
      return null;
    }

    return _prefs!.getBool(_biometricEnabled);
  }

  static Future<void> setBiometricType(BiometricType? type) async {
    if (!_checkInitialized()) {
      return;
    }

    if (type != null) {
      await _prefs!.setString(_biometricTypeOrderKey, type.name);
    } else {
      await _prefs!.remove(_biometricTypeOrderKey);
    }
  }

  static String? getBiometricType() {
    if (!_checkInitialized()) {
      return null;
    }

    return _prefs!.getString(_biometricTypeOrderKey);
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
        print(
            'Storage not initialized. Please make sure to run StorageProvider.init()');
      }
      return false;
    }
    return true;
  }
}
