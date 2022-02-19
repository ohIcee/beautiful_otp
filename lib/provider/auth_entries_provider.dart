import 'dart:convert';

import 'package:beautiful_otp/models/auth_entry.dart';
import 'package:beautiful_otp/services/storage_service.dart';
import 'package:flutter/cupertino.dart';

class AuthEntriesProvider extends ChangeNotifier {
  List<AuthEntry> _authEntries = [];

  List<AuthEntry> get getEntries {
    return _authEntries;
  }

  Future saveEntriesToStorage() async {
    List<String> entriesJson = [];
    for (var entry in _authEntries) {
      entriesJson.add(jsonEncode(entry.toJson()));
    }
    await StorageService.setAuthEntries(entriesJson);
  }

  void setEntries(List<AuthEntry> entries, {bool saveToStorage = false}) {
    _authEntries = entries;

    if (saveToStorage) {
      saveEntriesToStorage();
    }
  }

  void removeAllEntries() {
    StorageService.setAuthEntries([]);
    _authEntries.clear();
    notifyListeners();
  }

  void removeEntry(AuthEntry entry) {
    _authEntries.remove(entry);
    notifyListeners();

    saveEntriesToStorage();
  }

  void addMultipleEntries(List<AuthEntry> entries) {
    _authEntries.addAll(entries);
    notifyListeners();

    saveEntriesToStorage();
  }

  void addEntry(AuthEntry entry) {
    _authEntries.add(entry);
    notifyListeners();

    saveEntriesToStorage();
  }
}