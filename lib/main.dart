import 'settings/knowingthestudent.dart';
import 'package:flutter/material.dart';
import 'home/home_page.dart';
import 'settings/settings_page.dart';
import 'settings/preferred_time.dart';
import 'package:firebase_core/firebase_core.dart';
import 'journal/journal_page.dart';
import 'firebase_options.dart';
import 'setup/authentication_page.dart';
import 'settings/habitica_integration_page.dart';
import 'settings/apps_selection_page.dart';
import 'core/loader.dart';
import 'color_schemes.g.dart';
import 'core/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  bool isLoggedIn = await SessionManager.getLoginState();
  await LocalNotificationService().init();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mentor',
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      themeMode: ThemeMode.system,
      home: isLoggedIn ? const MentorPage() : const EmailAuth(),
      routes: {
        //main pages
        '/settings': (context) => const SettingsPage(),
        '/journal': (context) => const JournalPage(),
        '/mentor': (context) => const MentorPage(),

        //Settings Subroute

        '/appsSelection': (context) => const AppSelectionPage(),
        '/habiticaIntegrationPage': (context) =>
            const HabiticaIntegrationPage(),
        '/knowingthestudent': (context) => const Knowingthestudent(),
        '/preferredtime': (context) => PreferredTimePage(),
      },
    );
  }
}
