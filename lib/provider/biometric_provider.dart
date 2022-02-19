import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';

import '../services/storage_service.dart';

class BiometricProvider extends ChangeNotifier {
  bool biometricsEnabled = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  LocalAuthentication get localAuth => _localAuth;

  bool biometricsAvailable = false;

  void setBiometricsAvailable(bool available) async {
    biometricsAvailable = available;

    bool? enabled = await StorageService.getBiometricEnabled();
    if (!biometricsAvailable && (enabled != null && enabled)) {
      setBiometricEnabled(enabled);
    }
  }

  void setBiometricEnabled(bool enabled, {bool saveToStorage = true}) {
    biometricsEnabled = enabled;
    notifyListeners();

    if (saveToStorage) {
      _saveToStorage();
    }
  }

  Future _saveToStorage() async {
    await StorageService.setBiometricEnabled(biometricsEnabled);
  }

  Future toggleBiometricsEnabled() async {
    biometricsEnabled = !biometricsEnabled;
    _saveToStorage();
    notifyListeners();
  }
}