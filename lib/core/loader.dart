import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_apps/device_apps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'data.dart';

class SessionManager {
  static const String loggedInKey = 'loggedIn';

  static Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loggedInKey, isLoggedIn);
  }

  static Future<bool> getLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loggedInKey) ?? false;
  }
}

class Loader {
  final _securestorage = const FlutterSecureStorage();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<List<Application>> loadselectedApps() async {
    final SharedPreferences _storage = await _prefs;
    List<String>? selectedApps = _storage.getStringList('selectedApps');
    if (selectedApps != null) {
      Data.selectedApps = Data.loadedApps
          .where((app) => selectedApps.contains(app.appName))
          .toList();
    }
    return Data.selectedApps;
  }

  Future<void> saveSelectedApps() async {
    final SharedPreferences prefs = await _prefs;
    List<String> selectedAppNames =
        Data.selectedApps.map((app) => app.appName).toList();
    await prefs.setStringList('selectedApps', selectedAppNames);
  }

  static Future<List<Application>> loadApps() async {
    List<Application> loaded_apps = await DeviceApps.getInstalledApplications(
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    loaded_apps.sort((a, b) => a.appName.compareTo(b.appName));
    Data.loadedApps = loaded_apps;
    return loaded_apps;
  }

  Future<String?> loadcompletion() async {
    final SharedPreferences _storage = await _prefs;
    String? completion = _storage.getString('completion');
    if (completion != null) {
      Data.completion_message = completion;
    }
    return completion;
  }

  void savecompletion(String completion) async {
    completion = completion;
    final SharedPreferences _storage = await _prefs;
    _storage.setString('completion', completion);
  }

  static Future<List<QueryDocumentSnapshot>> loadjournal() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('journals')
        .where('userId', isEqualTo: Data.userId)
        .where('title',
            isGreaterThan: Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 3))))
        .get();
    List<QueryDocumentSnapshot> documents = snapshot.docs;
    return documents;
  }

  Future<String> loadserverurl() async {
    final SharedPreferences _storage = await _prefs;
    String server_url = await _storage.getString('server_url') ??
        'https://prasannanrobots.pythonanywhere.com/mentor';
    return server_url;
  }

  void saveserverurl(String server_url) async {
    final SharedPreferences _storage = await _prefs;
    // Encrypt and save the data locally
    await _storage.setString('server_url', server_url);
  }

  Future<Map<String, String?>> loadHabiticaDetails() async {
    String? habiticaUserId = await _securestorage.read(key: 'habitica_user_id');
    String? habiticaApiKey = await _securestorage.read(key: 'habitica_api_key');
    return {
      'userId': habiticaUserId,
      'apiKey': habiticaApiKey,
    };
  }

  void saveHabiticaDetails(String habiticaUserId, String habiticaApiKey) async {
    await _securestorage.write(
      key: 'habitica_user_id',
      value: habiticaUserId,
    );
    await _securestorage.write(
      key: 'habitica_api_key',
      value: habiticaApiKey,
    );
  }

  Future<Map<String, String?>> load_user_stuff() async {
    final SharedPreferences _storage = await _prefs;
    String? loadedUserGoal = await _storage.getString('userGoal');
    String? loadedSelfPerception = await _storage.getString('selfPerception');

    Map<String, String?> userStuff = {
      "userGoal": loadedUserGoal,
      "selfPerception": loadedSelfPerception
    };
    return userStuff;
  }

  void save_user_stuff(String userGoal, String selfPerception) async {
    final SharedPreferences _storage = await _prefs;
    await _storage.setString('userGoal', userGoal);
    await _storage.setString('selfPerception', selfPerception);
  }
}
