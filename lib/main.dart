import 'package:flutter/material.dart';
import 'home_page.dart';
import 'settings_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mentor',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MentorPage(),
      routes: {
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
