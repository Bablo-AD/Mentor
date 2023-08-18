import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_apps/device_apps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

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

  void saveScheduleTime(String selectedTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('scheduledTime', selectedTime);
  }

  Future<String?> loadScheduledTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final scheduledTime = prefs.getString('scheduledTime');
    return scheduledTime;
  }

  void saveMessages(List<Messages> messages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert messages list to JSON string
    List<String> jsonList =
        messages.map((message) => jsonEncode(message.toJson())).toList();
    Data.messages_data = messages;
    // Save the JSON string list to SharedPreferences
    await prefs.setStringList('messages', jsonList);
  }

  Future<List<Messages>> loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON string list from SharedPreferences
    List<String>? jsonList = prefs.getStringList('messages');

    // Convert JSON string list to Messages list
    List<Messages> messages = [];
    if (jsonList != null) {
      for (String jsonString in jsonList) {
        Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        Messages message = Messages(
          role: jsonMap['role'],
          content: jsonMap['content'],
        );
        messages.add(message);
      }
      Data.messages_data = messages;
    }

    return messages;
  }

  Future<List<Application>> loadselectedApps() async {
    final SharedPreferences storage = await _prefs;
    List<String>? selectedApps = storage.getStringList('selectedApps');
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
    List<Application> loadedApps = await DeviceApps.getInstalledApplications(
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    loadedApps.sort((a, b) => a.appName.compareTo(b.appName));
    Data.loadedApps = loadedApps;
    return loadedApps;
  }

  Future<String?> loadcompletion() async {
    final SharedPreferences storage = await _prefs;
    String? completion = storage.getString('completion');
    if (completion != null) {
      Data.completion_message = completion;
    }
    return completion;
  }

  void savecompletion(String completion) async {
    completion = completion;
    final SharedPreferences storage = await _prefs;
    storage.setString('completion', completion);
  }

  static Future<List<QueryDocumentSnapshot>> loadjournal() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(Data.userId)
        .collection("journal")
        .where('title',
            isGreaterThan: Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 3))))
        .get();
    List<QueryDocumentSnapshot> documents = snapshot.docs;
    return documents;
  }

  Future<String> loadserverurl() async {
    final SharedPreferences storage = await _prefs;
    String serverUrl = storage.getString('server_url') ??
        'https://prasannanrobots.pythonanywhere.com/mentor/chat';
    return serverUrl;
  }

  void saveserverurl(String serverUrl) async {
    final SharedPreferences storage = await _prefs;
    // Encrypt and save the data locally
    await storage.setString('server_url', serverUrl);
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
    final SharedPreferences storage = await _prefs;
    String? loadedUserGoal = storage.getString('userGoal');
    String? loadedSelfPerception = storage.getString('selfPerception');

    Map<String, String?> userStuff = {
      "userGoal": loadedUserGoal,
      "selfPerception": loadedSelfPerception
    };
    return userStuff;
  }

  void save_user_stuff(String userGoal, String selfPerception) async {
    final SharedPreferences storage = await _prefs;
    await storage.setString('userGoal', userGoal);
    await storage.setString('selfPerception', selfPerception);
  }
}
