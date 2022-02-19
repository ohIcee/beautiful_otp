import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:beautiful_otp/models/auth_entry.dart';
import 'package:beautiful_otp/provider/auth_entries_provider.dart';
import 'package:beautiful_otp/provider/biometric_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _snackbarHeight = 0.0;
  final double _expandedSnackbarHeight = 90.0;
  String _snackbarContent = '';
  Timer? _topSnackbarTimer;

  @override
  void dispose() {
    _topSnackbarTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          _buildContent(),
          _buildTopSnackbar(),
        ],
      ),
    );
  }

  void showSnackbar(String text, Duration duration) {
    setState(() {
      _snackbarContent = text;
      _snackbarHeight = _expandedSnackbarHeight;
    });

    _topSnackbarTimer = Timer(duration, () {
      setState(() {
        _snackbarHeight = 0.0;
      });
    });
  }

  Widget _buildTopSnackbar() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCirc,
        width: 50.0,
        height: _snackbarHeight,
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).primaryColor,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15.0, left: 40.0, right: 40.0),
            child: Text(
              _snackbarContent,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).viewPadding.top + 10.0,
        left: 40.0,
        right: 40.0,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CupertinoNavigationBarBackButton(
                color: CupertinoTheme.of(context).primaryColor,
              ),
              Text(
                'Settings',
                style: TextStyle(
                  color: CupertinoTheme.of(context).primaryColor,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25.0),
          ListView(
            shrinkWrap: true,
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
          onChanged: Provider.of<BiometricProvider>(context, listen: false)
                  .biometricsAvailable
              ? onBiometricSwitched
              : null,
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
      DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      String filename =
          'beautiful-otp-export-' + formatter.format(now) + '.json';
      File file = File('$path/$filename');
      await file.writeAsString(json);

      if (kDebugMode) {
        print("File Written to $filename");
      }

      showSnackbar('Exported to\n$filename', const Duration(seconds: 3));
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

      showSnackbar('Successfully imported ${entries.length} items!', const Duration(seconds: 2));
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
