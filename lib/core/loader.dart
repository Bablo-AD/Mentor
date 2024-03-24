import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:device_apps/device_apps.dart';
import 'data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home/make_request.dart';
import '../core/notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

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
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  @pragma('vm:entry-point')
  static void makerequest() async {
    print("alarm");
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    LocalNotificationService notifier = LocalNotificationService();
    //notifier.showNotificationAndroid('Executing', "Building report");

    try {
      DataProcessor dataGetter = DataProcessor();
      await dataGetter.execute();
    } catch (e) {
      print(e);
    }
    notifier.showNotificationAndroid(
        Data.notification_title, Data.notification_body);
    // Retrieve the SendPort from the IsolateNameServer
    final SendPort? sendPort =
        IsolateNameServer.lookupPortByName('background_isolate');

    // Send the completion message back to the main isolate
    sendPort?.send(
        {'completion': Data.completion_message, 'videoList': Data.videoList});
  }

  Future<void> saveVideoList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> videoListJson =
        Data.videoList.map((video) => jsonEncode(video.toJson())).toList();
    await prefs.setStringList('videoList', videoListJson);
  }

  Future<List<Video>> loadVideoList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? videoListJson = prefs.getStringList('videoList');
    if (videoListJson == null) {
      return [];
    } else {
      return videoListJson
          .map((videoJson) => Video.fromJson(jsonDecode(videoJson)))
          .toList();
    }
  }

  Future<void> clearMessageHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('message_history');
    await prefs.remove('messages');
  }

  Future<void> saveMessageHistory(String messages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('message_history', messages);
  }

  Future<String> loadMessageHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('message_history') ?? '';
  }

  static Future<List<Application>> loadApps() async {
    List<Application> loadedApps = await DeviceApps.getInstalledApplications(
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
    );
    List<Application> sortedApps = List<Application>.from(loadedApps);
    sortedApps.sort((a, b) => a.appName.compareTo(b.appName));
    Data.apps = sortedApps;
    return sortedApps;
  }

  static String load_user_id() {
    String? userid = FirebaseAuth.instance.currentUser?.uid;
    return userid ?? "";
  }

  Future<List<Application>> loadSelectedApps() async {
    await Loader.loadApps();
    final SharedPreferences prefss = await prefs;
    List<String>? selectedAppNames = prefss.getStringList('selectedApps') ?? [];

    List<Application> selectedApps = Data.apps
        .where((app) => selectedAppNames.contains(app.appName))
        .toList();

    Data.selected_apps = selectedApps;
    return selectedApps;
  }

  Future<void> saveSelectedApps() async {
    final SharedPreferences prefss = await prefs;
    List<String> selectedAppNames =
        Data.selected_apps.map((app) => app.appName).toList();
    await prefss.setStringList('selectedApps', selectedAppNames);
  }

  Future<void> saveSelectedTime(TimeOfDay time) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedHour', time.hour);
    await prefs.setInt('selectedMinute', time.minute);
  }

  Future<TimeOfDay?> getSelectedTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? hour = prefs.getInt('selectedHour');
    final int? minute = prefs.getInt('selectedMinute');

    if (hour != null && minute != null) {
      return TimeOfDay(hour: hour, minute: minute);
    } else {
      return null;
    }
  }

  void saveMessages(List<types.Message> messages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert messages list to JSON string
    List<String> jsonList =
        messages.map((message) => jsonEncode(_messageToJson(message))).toList();

    // Save the JSON string list to SharedPreferences
    await prefs.setStringList('messages', jsonList);
  }

  Map<String, dynamic> _messageToJson(types.Message message) {
    return message.toJson();
  }

  Future<List<types.Message>> loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> messages = prefs.getStringList('messages') ?? [];
    List<types.Message> messageList = [];
    for (var message in messages) {
      try {
        messageList.add(types.TextMessage.fromJson(jsonDecode(message)));
      } catch (e) {
        print('Error decoding message: $e, $message');
      }
    }
    return messageList;
  }

  Future<String?> loadcompletion() async {
    final SharedPreferences storage = await prefs;
    String? completion = storage.getString('completion');
    if (completion != null) {
      Data.completion_message = completion;
    }
    return completion;
  }

  void savecompletion(String completion) async {
    final SharedPreferences storage = await prefs;
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
    final SharedPreferences storage = await prefs;
    String serverUrl = storage.getString('server_url') ??
        'https://prasannanrobots.pythonanywhere.com/mentor/chat/mentorlite';
    return serverUrl;
  }

  void saveserverurl(String serverUrl) async {
    final SharedPreferences storage = await prefs;
    // Encrypt and save the data locally
    await storage.setString('server_url', serverUrl);
  }

  Future<Map<String, String?>> loadHabiticaDetails() async {
    final SharedPreferences storage = await prefs;
    String? habiticaUserId = storage.getString('habitica_user_id');
    String? habiticaApiKey = storage.getString('habitica_api_key');
    return {
      'userId': habiticaUserId,
      'apiKey': habiticaApiKey,
    };
  }

  void saveHabiticaDetails(String habiticaUserId, String habiticaApiKey) async {
    final SharedPreferences storage = await prefs;
    await storage.setString('habitica_user_id', habiticaUserId);
    await storage.setString('habitica_api_key', habiticaApiKey);
  }

  Future<Map<String, String?>> load_user_stuff() async {
    final SharedPreferences storage = await prefs;
    String? loadedUserGoal = storage.getString('userGoal');
    String? loadedSelfPerception = storage.getString('selfPerception');

    Map<String, String?> userStuff = {
      "userGoal": loadedUserGoal,
      "selfPerception": loadedSelfPerception
    };
    return userStuff;
  }

  void save_user_stuff(String userGoal, String selfPerception) async {
    final SharedPreferences storage = await prefs;
    await storage.setString('userGoal', userGoal);
    await storage.setString('selfPerception', selfPerception);
  }
}
