import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:device_apps/device_apps.dart';
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
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<List<Application>> loadApps() async {
    List<Application> loaded_apps = await DeviceApps.getInstalledApplications(
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    List<Application> sortedApps = List<Application>.from(loaded_apps);
    sortedApps.sort((a, b) => a.appName.compareTo(b.appName));
    Data.apps = sortedApps;
    return sortedApps;
  }

  Future<List<Application>> loadSelectedApps() async {
    final SharedPreferences prefs = await _prefs;
    List<String>? selectedAppNames = prefs.getStringList('selectedApps') ?? [];
    await Loader.loadApps();
    List<Application> selectedApps = Data.apps
        .where((app) => selectedAppNames.contains(app.appName))
        .toList();
    Data.selected_apps = selectedApps;
    return selectedApps;
  }

  Future<void> saveSelectedApps() async {
    final SharedPreferences prefs = await _prefs;
    List<String> selectedAppNames =
        Data.selected_apps.map((app) => app.appName).toList();
    await prefs.setStringList('selectedApps', selectedAppNames);
  }

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
    final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(Data.userId)
        .get();

    if (documentSnapshot['messages'] != null) {
      Map<String, dynamic> messageData =
          jsonDecode(documentSnapshot['messages']);
      List<dynamic> body = messageData['body'];
      return body
          .map((message) {
            return Messages(
              role: message['role'],
              content: message['content'],
            );
          })
          .toList()
          .cast<Messages>();
    } else {
      return [];
    }
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
                DateTime.now().subtract(const Duration(days: 1))))
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
    final SharedPreferences storage = await _prefs;
    String? habiticaUserId = storage.getString('habitica_user_id');
    String? habiticaApiKey = storage.getString('habitica_api_key');
    return {
      'userId': habiticaUserId,
      'apiKey': habiticaApiKey,
    };
  }

  void saveHabiticaDetails(String habiticaUserId, String habiticaApiKey) async {
    final SharedPreferences storage = await _prefs;
    await storage.setString('habitica_user_id', habiticaUserId);
    await storage.setString('habitica_api_key', habiticaApiKey);
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
