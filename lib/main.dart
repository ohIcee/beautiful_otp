import 'package:beautiful_otp/views/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
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
    );
  }
}
