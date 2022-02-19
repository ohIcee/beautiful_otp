import 'dart:async';

import 'package:animated_fractionally_sized_box/animated_fractionally_sized_box.dart';
import 'package:beautiful_otp/components/bottom_nav.dart';
import 'package:beautiful_otp/models/auth_entry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List<String> aegisBackupCodes = [
  //   "otpauth://totp/Discord%3Aicevx1%40gmail.com?period=30&digits=6&algorithm=SHA1&secret=ZO33BBMP55JY3IKK&issuer=Discord",
  //   "otpauth://totp/FaceIt%3AIceeCold?period=30&digits=6&algorithm=SHA1&secret=BN45VYXPRT4HCIQZ&issuer=FaceIt",
  //   "otpauth://totp/EFT%3AbyIcee?period=30&digits=6&algorithm=SHA1&secret=C2JMA6GKOY5T2GYV2DFMFS7EGWDJBYQ3&issuer=EFT",
  //   "otpauth://totp/Bitfinex%3ABitfinex-9-2-2020?period=30&digits=6&algorithm=SHA1&secret=RJNXVP6Y4SNQNAGY&issuer=Bitfinex",
  //   "otpauth://totp/EFT%3AohIcee?period=30&digits=6&algorithm=SHA1&secret=NGD7X6A3KAKDZMPFTISQUTMAHATA6EAK&issuer=EFT",
  //   "otpauth://totp/Argentas%3Aicevx1%40gmail.com?period=30&digits=6&algorithm=SHA1&secret=2CVJXXSV47D3RYQH&issuer=Argentas",
  //   "otpauth://totp/Celsius%3ACelsius?period=30&digits=6&algorithm=SHA1&secret=GJFXWKCBLIXGY32PKB3SC3KWKAXCUZDE&issuer=Celsius",
  //   "otpauth://totp/Nexo%3Aicevx1%40gmail.com?period=30&digits=6&algorithm=SHA1&secret=YWP5YPFETQOMUE7E&issuer=Nexo",
  //   "otpauth://totp/CakeDEFI%3Aicevx1%40gmail.com?period=30&digits=6&algorithm=SHA1&secret=OJZGK6TNGV2W4ZRQ&issuer=CakeDEFI",
  // ];

  List<AuthEntry> authEntries = [];

  Map<AuthEntry, String> previousOtpCodes = {};
  Map<AuthEntry, String> otpCodes = {};

  int timerTimeLeft = 30;

  double _snackbarHeight = 0.0;
  final double _expandedSnackbarHeight = 90.0;

  @override
  void initState() {
    super.initState();

    // for (var backupCode in aegisBackupCodes) {
    //   authEntries.add(AuthEntry.fromGauthString(backupCode, true));
    // }

    refreshTokens();

    timerTimeLeft =
        (30 - (DateTime.now().millisecondsSinceEpoch / 1000) % 30).round() - 2;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      refreshTokens();
      setState(() => timerTimeLeft -= 1);

      if (timerTimeLeft < -1) {
        if (kDebugMode) {
          print('Time out of sync by more than 1 second! Re-syncing...');
        }
        setState(() {
          timerTimeLeft =
              (30 - (DateTime.now().millisecondsSinceEpoch / 1000) % 30)
                      .round() -
                  2;
        });
      }
    });
  }

  void refreshTokens() {
    previousOtpCodes = otpCodes;
    otpCodes = {};

    for (var entry in authEntries) {
      otpCodes[entry] = entry.totp!.now();
    }

    if (!const DeepCollectionEquality().equals(previousOtpCodes, otpCodes)) {
      setState(() {
        timerTimeLeft = 30;
      });
    }

    setState(() {
      previousOtpCodes = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          _buildContent(),
          const BottomNav(),
          _buildTopSnackbar(),
        ],
      ),
    );
  }

  void showSnackbar() {
    setState(() {
      _snackbarHeight = _expandedSnackbarHeight;
    });

    Timer(const Duration(seconds: 1), () {
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
        decoration: const BoxDecoration(
          color: CupertinoColors.destructiveRed,
        ),
        child: const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 15.0),
            child: Text(
              'OTP Code copied to clipboard!',
              style: TextStyle(
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
          top: MediaQuery.of(context).viewPadding.top + 25.0,
          left: 25.0,
          right: 25.0,
          bottom: MediaQuery.of(context).padding.bottom + 55.0),
      child: Column(
        children: [
          _buildRefreshTimer(),
          const SizedBox(height: 15.0),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: authEntries.length,
              itemBuilder: (context, index) {
                return _buildAuthEntry(authEntries[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshTimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: timerTimeLeft.clamp(0, 30).toString() + '.0'),
                const TextSpan(text: 's'),
              ],
            ),
            style: TextStyle(
              fontSize: 15.0,
              color: CupertinoTheme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 20.0),
          Expanded(
            child: SizedBox(
              height: 5.0,
              child: Stack(
                children: [
                  Container(
                    color:
                        CupertinoTheme.of(context).primaryColor.withOpacity(.1),
                  ),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCirc,
                    widthFactor: (timerTimeLeft / 30.0).clamp(0, 1),
                    child: Container(
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthEntry(AuthEntry entry) {
    // String otpCode = entry.totp!.now();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Dismissible(
        key: Key(entry.secret!),
        direction: DismissDirection.startToEnd,
        background: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.destructiveRed,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                CupertinoIcons.delete_solid,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),
        onDismissed: (DismissDirection direction) {
          setState(() => authEntries.remove(entry));
        },
        confirmDismiss: (DismissDirection direction) async {
          return await showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                    title: const Text("Delete entry"),
                    content: Column(
                      children: const [
                        Text(
                            'Make sure you disable 2FA on the application BEFORE deleting this entry!'),
                        Text(
                            'This is a destructive action. You can not get this back unless you have a backup.'),
                      ],
                    ),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: const Text("Confirm"),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                      CupertinoDialogAction(
                        child: const Text("Dismiss"),
                        onPressed: () => Navigator.of(context).pop(false),
                      )
                    ],
                  ));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.issuer!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    Text(
                      entry.name!,
                      style: TextStyle(
                        color: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .color!
                            .withOpacity(.55),
                        fontSize: 15.0,
                      ),
                    ),
                  ],
                ),
              ),
              _buildAuthEntryCode(otpCodes[entry]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthEntryCode(String? otpCode) {
    TextStyle digitStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 17.0,
    );

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 39.0),
        child: GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: otpCode)).then((_) {
              showSnackbar();
            });
          },
          child: Container(
            height: 40.0,
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 5.0,
            ),
            decoration: BoxDecoration(
              color: CupertinoTheme.of(context).primaryColor.withOpacity(.08),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: otpCode == null
                ? const Center(
                    child: Text(
                    'ERROR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(otpCode[0], style: digitStyle),
                      Text(otpCode[1], style: digitStyle),
                      Text(otpCode[2], style: digitStyle),
                      const SizedBox(width: 4.0),
                      Text(otpCode[3], style: digitStyle),
                      Text(otpCode[4], style: digitStyle),
                      Text(otpCode[5], style: digitStyle),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
