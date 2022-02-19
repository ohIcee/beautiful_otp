import 'dart:async';

import 'package:beautiful_otp/models/auth_entry.dart';
import 'package:beautiful_otp/provider/auth_entries_provider.dart';
import 'package:beautiful_otp/views/qr_scanner.dart';
import 'package:beautiful_otp/views/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  String newEntryOtpCode = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: MediaQuery.of(context).padding.bottom + 55.0,
            decoration: BoxDecoration(
                color: CupertinoTheme.of(context).primaryColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10.0))),
            padding: EdgeInsets.only(
              top: 10.0,
              left: 10.0,
              right: 10.0,
              bottom: MediaQuery.of(context).viewPadding.bottom,
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              reverse: true,
              children: [
                _buildButton('Add Item', CupertinoIcons.add, _onAddItemButton),
                const SizedBox(width: 10.0),
                _buildButton(
                    'Settings',
                    CupertinoIcons.gear_alt_fill,
                    () => Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => const SettingsPage()))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onAddItemButton() async {
    Object? result = await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => const QrScanner()),
    );

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ));

    // If user scanned a QR code and returned an AuthEntry
    if (result.runtimeType == AuthEntry) {
      AuthEntry entry = result as AuthEntry;
      entry.printInfo();
      entry.generateTOTP();
      setState(() {
        newEntryOtpCode = entry.totp!.now();
      });

      Provider.of<AuthEntriesProvider>(context, listen: false)
          .addEntry(entry);

      TextStyle digitStyle = const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 17.0,
        color: CupertinoColors.white,
      );

      Timer? timer;
      await showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: const Text('Enter code into your app'),
          message: StatefulBuilder(builder: (context, setState) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
              setState(() {
                newEntryOtpCode = entry.totp!.now();
              });
            });

            return Container(
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(newEntryOtpCode[0], style: digitStyle),
                  Text(newEntryOtpCode[1], style: digitStyle),
                  Text(newEntryOtpCode[2], style: digitStyle),
                  const SizedBox(width: 10.0),
                  Text(newEntryOtpCode[3], style: digitStyle),
                  Text(newEntryOtpCode[4], style: digitStyle),
                  Text(newEntryOtpCode[5], style: digitStyle),
                ],
              ),
            );
          }),
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Finish'),
            isDefaultAction: true,
            onPressed: () {
              timer!.cancel();
              Navigator.pop(context, 'cancel');
            },
          ),
        ),
      );

      timer!.cancel();
    }
  }

  Widget _buildButton(String name, IconData? icon, Function() onTap) {
    return ElevatedButton(
      child: Row(
        children: [
          Icon(
            icon!,
            size: 20.0,
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
          const SizedBox(width: 10.0),
          Text(
            name,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1!.color,
            ),
          ),
        ],
      ),
      onPressed: onTap,
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all(CupertinoColors.white.withOpacity(.3)),
        elevation: MaterialStateProperty.all(0.0),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
