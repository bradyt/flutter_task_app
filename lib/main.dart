import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_task_app/components/config.dart';
import 'package:flutter_task_app/components/home.dart';
import 'package:flutter_task_app/components/loading.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String title =
      'task0${kDebugMode ? ' 🐞' : (kProfileMode ? ' 🚀' : '')}';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      routes: {
        '/': (context) => Loading(),
        '/home': (context) => Home(),
        '/config': (context) => Configuration()
      },
    );
  }
}
