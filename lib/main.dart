import 'package:beautiful_otp/provider/auth_entries_provider.dart';
import 'package:beautiful_otp/provider/biometric_provider.dart';
import 'package:beautiful_otp/services/storage_service.dart';
import 'package:beautiful_otp/views/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthEntriesProvider>(
            create: (_) => AuthEntriesProvider()),
        ChangeNotifierProvider<BiometricProvider>(
            create: (_) => BiometricProvider()),
      ],
      child: const CupertinoApp(
        theme: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: Color(0xFFE44F5C),
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
              color: Color(0xFF44181C),
            ),
          ),
        ),
        home: HomePage(),
      ),
    );
  }
}
