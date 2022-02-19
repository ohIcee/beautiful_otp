import 'package:beautiful_otp/provider/auth_entries_provider.dart';
import 'package:beautiful_otp/services/storage_service.dart';
import 'package:beautiful_otp/views/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFFE44F5C),
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            color: Color(0xFF44181C),
          ),
        ),
      ),
      home: ChangeNotifierProvider<AuthEntriesProvider>(
        create: (context) => AuthEntriesProvider(),
        child: const HomePage(),
      ),
    );
  }
}
