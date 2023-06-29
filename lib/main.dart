import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import './widgets/main_view.dart';
import './providers/tcp_client.dart';
import './providers/logs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    await DesktopWindow.setMinWindowSize(const Size(600, 800));
  }
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TcpClient()),
        ChangeNotifierProvider(create: (context) => Logs()),
      ],
      child: MaterialApp(
        title: 'Flutter Spotify UI',
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData(
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromARGB(204, 255, 255, 255)),
          scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
          backgroundColor: const Color(0xFF121212),
          primaryColor: Colors.black,
          accentColor: const Color(0xFF1DB954),
          iconTheme: const IconThemeData().copyWith(color: Colors.white),
          fontFamily: 'Montserrat',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        home: MainView(),
      ),
    );
  }
}

String addToConsoleBuffer(String text, String bufferedText) {
  return '$bufferedText\n$text';
}

String dumpHexToString(List<int> data) {
  StringBuffer sb = StringBuffer();
  data.forEach((f) {
    sb.write(f.toRadixString(16).padLeft(2, '0'));
    sb.write(" ");
  });
  return sb.toString();
}
