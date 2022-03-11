import 'package:flutter/material.dart';
import 'package:test_webrtc/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // startForegroundService();
  runApp(const MyApp());
}

// Future<bool> startForegroundService() async {
//   const androidConfig = FlutterBackgroundAndroidConfig(
//     notificationTitle: 'Title of the notification',
//     notificationText: 'Text of the notification',
//     notificationImportance: AndroidNotificationImportance.Default,
//     notificationIcon: AndroidResource(
//         name: 'background_icon',
//         defType: 'drawable'), // Default is ic_launcher from folder mipmap
//   );
//   await FlutterBackground.initialize(androidConfig: androidConfig);
//   return FlutterBackground.enableBackgroundExecution();
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebRTC Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
