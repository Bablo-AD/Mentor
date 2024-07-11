import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:ui';

import 'screen/settings/knowingthestudent.dart';
import 'screen/home/home_page.dart';
import 'screen/settings/settings_page.dart';
import 'screen/settings/preferred_time.dart';
import 'screen/journal/journal_page.dart';
import 'screen/settings/habitica_integration_page.dart';
import 'screen/settings/apps_selection_page.dart';
import 'utils/notifications.dart';
import 'utils/data.dart';
import 'utils/util.dart';
import 'utils/theme.dart';
import 'screen/home/mentor_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AndroidAlarmManager.initialize();
  await LocalNotificationService().init();
  IsolateNameServer.registerPortWithName(
    Data.port.sendPort,
    'background_isolate',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    // Retrieves the default theme for the platform
    //TextTheme textTheme = Theme.of(context).textTheme;

    // Use with Google Fonts package to use downloadable fonts
    TextTheme textTheme =
        createTextTheme(context, "Oxygen Mono", "Oxygen Mono");

    MaterialTheme theme = MaterialTheme(textTheme);
    return MaterialApp(
      title: 'Mentor',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: const HomePage(),
      routes: {
        //main pages
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/journal': (context) => const JournalPage(),
        '/mentor': (context) => const MentorPage(),

        //Settings Subroute

        '/appsSelection': (context) => const AppSelectionPage(),
        '/habiticaIntegrationPage': (context) =>
            const HabiticaIntegrationPage(),
        '/knowingthestudent': (context) => const Knowingthestudent(),
        '/preferredtime': (context) => const PreferredTimePage(),
      },
    );
  }
}
