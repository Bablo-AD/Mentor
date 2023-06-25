import 'package:flutter/material.dart';
import 'home/home_page.dart';
import 'settings/settings_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'journal/journal_page.dart';
import 'firebase_options.dart';
import 'setup/authentication_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  bool isLoggedIn = await SessionManager.getLoginState();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mentor',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Monospace'),
      home: isLoggedIn ? const MentorPage() : const EmailAuth(),
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/journal': (context) => const JournalPage(),
        '/mentor': (context) => const MentorPage(),
      },
    );
  }
}
