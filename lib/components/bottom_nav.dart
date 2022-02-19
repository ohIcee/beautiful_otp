import 'dart:async';

import 'package:beautiful_otp/models/auth_entry.dart';
import 'package:beautiful_otp/views/qr_scanner.dart';
import 'package:dart_otp/dart_otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                ElevatedButton(
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.arrow_down_to_line,
                        size: 20.0,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        'Import',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color,
                        ),
                      )
                    ],
                  ),
                  onPressed: () async {

                  },
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
                ),
                const SizedBox(width: 10.0),
                ElevatedButton(
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.add,
                        size: 20.0,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        'Add Item',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color,
                        ),
                      )
                    ],
                  ),
                  onPressed: () async {
                    String result = await showCupertinoModalPopup(
                      context: context,
                      builder: (context) => CupertinoActionSheet(
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
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context, 'manual');
                            },
                            child: const Text('Enter manually'),
                          ),
                        ],
                      ),
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
                        entry.totp = TOTP(
                          secret: entry.secret,
                          interval: entry.period,
                          digits: entry.digits,
                          algorithm: entry.algorithm,
                        );
                        setState(() {
                          newEntryOtpCode = entry.totp!.now();
                        });

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
                  },
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
                ),
                const SizedBox(width: 10.0),
                ElevatedButton(
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.settings_solid,
                        size: 20.0,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        'Settings',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {},
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
