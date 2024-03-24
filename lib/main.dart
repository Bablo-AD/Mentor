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
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:ui';
import 'core/data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AndroidAlarmManager.initialize();
  bool isLoggedIn = await SessionManager.getLoginState();
  await LocalNotificationService().init();
  IsolateNameServer.registerPortWithName(
    Data.port.sendPort,
    'background_isolate',
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  remoteConfig.setDefaults(<String, dynamic>{
    'serverurl':
        'https://prasannanrobots.pythonanywhere.com/mentor/chat/mentorlite',
  });
  await remoteConfig.fetchAndActivate();

  // Get the server URL
  Data.serverurl = remoteConfig.getString('serverurl');

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({Key? key, required this.isLoggedIn}) : super(key: key);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mentor',
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      themeMode: ThemeMode.system,
      home: StreamBuilder<User?>(
          stream: _auth.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data == null) {
                return const EmailAuth();
              } else {
                return const MentorPage();
              }
            }
            return const CircularProgressIndicator();
          }),
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
        '/preferredtime': (context) => const PreferredTimePage(),
      },
    );
  }
}
