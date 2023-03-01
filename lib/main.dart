import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

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
    return MaterialApp(
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
      home: Shell(),
    );
  }
}

class Shell extends StatelessWidget {
  Uint8List mbFrame = Uint8List.fromList([1, 3, 0, 20, 0, 2, 132, 15]);
  String modbusRequest = '';
  String consoleBufferedText = 'Log:';
  @override
  Widget build(BuildContext context) {
    // Socket.connect("localhost", 5020).then((socket) {
    //   String connectAddressPort =
    //       '${socket.remoteAddress.address}:${socket.remotePort}';
    //   consoleBufferedText =
    //       addToConsoleBuffer(connectAddressPort, consoleBufferedText);
    //   print(
    //       'Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

    //   socket.listen((data) {
    //     print('Response received:');
    //     print(data);
    //     print(dumpHexToString(data));
    //     print('Done');
    //     socket.destroy();
    //   }, onDone: () {
    //     print('Done');
    //     socket.destroy();
    //   });
    //   //Send request
    //   print(mbFrame);
    //   socket.add(mbFrame);
    // });
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Center(child: const Text('centered text')),
              ],
            ),
          ),
          Expanded(
              child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    // const BoxShadow(
                    //   color: Colors.black12,
                    // ),
                    // const BoxShadow(
                    //   color: Colors.black26,
                    //   spreadRadius: -12.0,
                    //   blurRadius: 12.0,
                    // ),
                  ],
                ),
                child: RichText(
                    text: TextSpan(
                        text: consoleBufferedText,
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: const <TextSpan>[])),
              )
            ],
          ))
        ],
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
