import 'dart:async';

import 'package:beautiful_otp/models/auth_entry.dart';
import 'package:beautiful_otp/provider/auth_entries_provider.dart';
import 'package:beautiful_otp/views/qr_scanner.dart';
import 'package:dart_otp/dart_otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  String newEntryOtpCode = '';

  List<String> aegisBackupCodes = [
    "otpauth://totp/Discord%3Aicevx1%40gmail.com?period=30&digits=6&algorithm=SHA1&secret=ZO33BBMP55JY3IKK&issuer=Discord",
    "otpauth://totp/FaceIt%3AIceeCold?period=30&digits=6&algorithm=SHA1&secret=BN45VYXPRT4HCIQZ&issuer=FaceIt",
    "otpauth://totp/EFT%3AbyIcee?period=30&digits=6&algorithm=SHA1&secret=C2JMA6GKOY5T2GYV2DFMFS7EGWDJBYQ3&issuer=EFT",
    "otpauth://totp/Bitfinex%3ABitfinex-9-2-2020?period=30&digits=6&algorithm=SHA1&secret=RJNXVP6Y4SNQNAGY&issuer=Bitfinex",
    "otpauth://totp/EFT%3AohIcee?period=30&digits=6&algorithm=SHA1&secret=NGD7X6A3KAKDZMPFTISQUTMAHATA6EAK&issuer=EFT",
    "otpauth://totp/Argentas%3Aicevx1%40gmail.com?period=30&digits=6&algorithm=SHA1&secret=2CVJXXSV47D3RYQH&issuer=Argentas",
    "otpauth://totp/Celsius%3ACelsius?period=30&digits=6&algorithm=SHA1&secret=GJFXWKCBLIXGY32PKB3SC3KWKAXCUZDE&issuer=Celsius",
    "otpauth://totp/Nexo%3Aicevx1%40gmail.com?period=30&digits=6&algorithm=SHA1&secret=YWP5YPFETQOMUE7E&issuer=Nexo",
    "otpauth://totp/CakeDEFI%3Aicevx1%40gmail.com?period=30&digits=6&algorithm=SHA1&secret=OJZGK6TNGV2W4ZRQ&issuer=CakeDEFI",
  ];

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
                _buildButton('', CupertinoIcons.ant_fill, () async {
                  for (var backupCode in aegisBackupCodes) {
                    Provider.of<AuthEntriesProvider>(context, listen: false)
                        .addEntry(
                        AuthEntry.fromGauthString(backupCode, true));
                  }
                }),
                const SizedBox(width: 10.0),
                _buildButton('Add Item', CupertinoIcons.add, _onAddItemButton),
                const SizedBox(width: 10.0),
                _buildButton('Settings', CupertinoIcons.ant_fill, () => null),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddItemActionSheet() => CupertinoActionSheet(
    title: const Text('Choose method'),
    cancelButton: CupertinoActionSheetAction(
      child: const Text('cancel'),
      isDefaultAction: true,
      onPressed: () {
        Navigator.pop(context, 'cancel');
      },
    ),
    actions: [
      CupertinoActionSheetAction(
        onPressed: () async {
          Navigator.pop(context, 'qr');
        },
        child: const Text('Scan QR Code'),
      ),
      // CupertinoActionSheetAction(
      //   onPressed: () => Navigator.pop(context, 'manual'),
      //   child: const Text('Enter manually'),
      // ),
      CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context, 'import');
        },
        child: const Text('Import from other 2FA App'),
      ),
    ],
  );

  void _onAddItemButton() async {
    String result = await showCupertinoModalPopup(
      context: context,
      builder: (context) => _buildAddItemActionSheet(),
    );

    if (result == 'qr') {
      Object? result = await Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => const QrScanner()),
      );

      // If user scanned a QR code and returned an AuthEntry
      if (result.runtimeType == AuthEntry) {
        AuthEntry entry = result as AuthEntry;
        entry.printInfo();
        entry.generateTOTP();
        setState(() {
          newEntryOtpCode = entry.totp!.now();
        });

        Provider.of<AuthEntriesProvider>(context, listen: false).addEntry(entry);

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
          message:
          StatefulBuilder(builder: (context, setState) {
            timer ??= Timer.periodic(
                const Duration(seconds: 1), (timer) {
              setState(() {
                newEntryOtpCode = entry.totp!.now();
              });
            });

            return Container(
              decoration: BoxDecoration(
                color:
                CupertinoTheme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
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
    else if (result == 'import') {

    }
    else if (result == 'manual') {}
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
        backgroundColor: MaterialStateProperty.all(
            CupertinoColors.white.withOpacity(.3)),
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
