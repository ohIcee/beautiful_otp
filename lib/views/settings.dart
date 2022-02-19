import 'dart:convert';
import 'dart:io';

import 'package:beautiful_otp/models/auth_entry.dart';
import 'package:beautiful_otp/provider/auth_entries_provider.dart';
import 'package:beautiful_otp/provider/biometric_provider.dart';
import 'package:beautiful_otp/services/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:local_auth/local_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        brightness: Brightness.light,
        backgroundColor: const Color(0x00000000),
        border: const Border(),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: CupertinoNavigationBarBackButton(
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
        middle: Text(
          'Settings',
          style: TextStyle(
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).viewPadding.top + 80.0,
        left: 40.0,
        right: 40.0,
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildBiometricRow(),
          const SizedBox(height: 40.0),
          CupertinoButton.filled(
            child: const Text('Import Data'),
            onPressed: importData,
          ),
          CupertinoButton(
            child: const Text('Export Data'),
            onPressed: exportData,
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricRow() {
    return Row(
      children: [
        Text(
          'Biometric Authentication',
          style: TextStyle(
            color: CupertinoTheme.of(context).textTheme.textStyle.color,
            fontWeight: FontWeight.w500,
            fontSize: 17.0,
          ),
        ),
        const SizedBox(width: 20.0),
        CupertinoSwitch(
          value: Provider.of<BiometricProvider>(context, listen: true)
              .biometricsEnabled,
          onChanged: Provider.of<BiometricProvider>(context, listen: false).biometricsAvailable ? onBiometricSwitched : null,
          activeColor: CupertinoTheme.of(context).primaryColor,
        ),
      ],
    );
  }

  void onBiometricSwitched(bool newValue) async {
    if (newValue) {
      bool authenticated =
          await Provider.of<BiometricProvider>(context, listen: false)
              .localAuth
              .authenticate(
                localizedReason: 'Authenticate yourself',
                biometricOnly: true,
              );

      if (authenticated) {
        Provider.of<BiometricProvider>(context, listen: false)
            .setBiometricEnabled(newValue);
      }
    } else {
      Provider.of<BiometricProvider>(context, listen: false)
          .setBiometricEnabled(newValue);
    }
  }

  Future exportData() async {
    List<AuthEntry> entries =
        Provider.of<AuthEntriesProvider>(context, listen: false).getEntries;
    var json = jsonEncode(entries.map((e) => e.toJson()).toList());

    try {
      String path = await _localPath;
      File file = File(
          '$path/beautiful-otp-export-' + DateTime.now().toString() + '.json');
      await file.writeAsString(json);

      if (kDebugMode) {
        print("File Written!");
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Unsupported operation' + e.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      // setState(() => _isLoading = false);
    }
  }

  Future importData() async {
    // bool agreed = await showCupertinoDialog(
    //   context: context,
    //   builder: (context) => CupertinoAlertDialog(
    //     title: const Text('Warning'),
    //     content: const Text(
    //         'You can only import a Beautiful OTP export file or an unencrypted Aegis Authenticator backup!'),
    //     actions: [
    //       CupertinoDialogAction(
    //         child: const Text('Understood'),
    //         onPressed: () => Navigator.pop(context, true),
    //       ),
    //       CupertinoDialogAction(
    //         child: const Text('Cancel'),
    //         onPressed: () => Navigator.pop(context, false),
    //       ),
    //     ],
    //   ),
    // );
    //
    // if (!agreed) return;

    String? option = await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Import File Format'),
        cancelButton: CupertinoActionSheetAction(
          child: const Text('cancel'),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context, 'beautiful-otp');
            },
            child: const Text('Beautiful OTP'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context, 'aegis');
            },
            child: const Text('Aegis Authenticator'),
          ),
        ],
      ),
    );

    if (option == null) return;

    if (option == 'aegis') {
      bool understood = await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Warning'),
          content: const Text('The Aegis backup file has to be unencrypted!'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Understood'),
              onPressed: () => Navigator.pop(context, true),
            ),
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
      );
      if (!understood) return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();

      List<AuthEntry> entries = getEntriesFromString(content, option);

      Provider.of<AuthEntriesProvider>(context, listen: false)
          .addMultipleEntries(entries);
    } else {
      // User canceled the picker
    }
  }

  List<AuthEntry> getEntriesFromString(String content, String service) {
    if (service == 'beautiful-otp')
      return getEntriesFromBeautifulOTPExport(content);
    else if (service == 'aegis') return getEntriesFromAegisBackup(content);
    return [];
  }

  List<AuthEntry> getEntriesFromAegisBackup(String content) {
    List<AuthEntry> entries = [];

    List<String> lines = content.split('\n');
    for (var line in lines) {
      if (line.isEmpty) continue;

      entries.add(AuthEntry.fromGauthString(line, true));
    }

    return entries;
  }

  List<AuthEntry> getEntriesFromBeautifulOTPExport(String jsonContent) {
    List<AuthEntry> entries = [];

    List<dynamic> items = jsonDecode(jsonContent);
    for (var element in items) {
      var item = element as Map<String, dynamic>;
      AuthEntry entry = AuthEntry.fromJson(item);
      entry.generateTOTP();
      entries.add(entry);
    }

    return entries;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }
}
