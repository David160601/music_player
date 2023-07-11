import 'package:flutter/material.dart';
import 'package:music_player/screens/tab_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.red,
          primaryColor: Colors.red,
          textTheme: const TextTheme(
              titleLarge: TextStyle(fontWeight: FontWeight.bold))),
      home: const TabScreen(),
    );
  }
}
