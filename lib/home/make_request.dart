import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'dart:convert';
import 'dart:io';

import '../core/loader.dart';
import '../core/data.dart';

class DataProcessor {
  final _loader = Loader();

  String? userId = FirebaseAuth.instance.currentUser?.uid;
  //Processes the request to be sent to the server
  Future<String> _preparing_data(String interest) async {
    String habits = '';
    String phoneUsageData = '';

    //Preparing Habitica Data
    Map<String, String?> details = await _loader.loadHabiticaDetails();
    String? habiticaUserid = details['userId'];
    String? apiKey = details['apiKey'];
    if (habiticaUserid != null && apiKey != null) {
      HabiticaData habiticaData = HabiticaData(habiticaUserid, apiKey);
      habits = await habiticaData.execute();
    }

    //Preparing phone usage data
    if (Platform.isAndroid) {
      PhoneUsage phoneUsage = PhoneUsage();
      phoneUsageData = await phoneUsage.getUsage();
    }

    //Preparing journal Data
    String journalDataList = await getJournalData(userId.toString())
        .then((journalDataList) => jsonEncode(journalDataList));

    //Preparing usergoal,self perception
    Map<String, String?> userStuff = await _loader.load_user_stuff();
    String usergoal = userStuff['userGoal'].toString();
    String selfperception = userStuff['selfPerception'].toString();
    // Prepare the data to send in the request
    habits = (habits != "" && habits.isNotEmpty) ? "habits= $habits," : "";
    String goal = (interest.isNotEmpty) ? "goal= $interest," : "";
    String journal = (journalDataList != "[]" && journalDataList.isNotEmpty)
        ? "journal= $journalDataList,"
        : "";
    String usage = (phoneUsageData != "\n" && phoneUsageData.isNotEmpty)
        ? "usage= $phoneUsageData,"
        : "";
    String mygoal = (userStuff['userGoal'] != null &&
            userStuff['userGoal']?.isNotEmpty == true)
        ? "mygoal= $usergoal,"
        : "";
    String myperception = (userStuff['selfPerception'] != null &&
            userStuff['selfPerception']?.isNotEmpty == true)
        ? "myperception= $selfperception"
        : "";

    // Prepare the data to send in the request
    String metaData = """
    $habits
    $goal
    $journal
    $usage
    $mygoal
    $myperception """;
    return metaData;
  }

  Future<http.Response> meet_with_server(String messageData) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(userId).get();
    String message = await _loader.loadMessageHistory();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    Map<String, String> data = {
      "user_id": FirebaseAuth.instance.currentUser?.uid.toString() ?? '',
      "apikey": userData['apikey'].toString(),
      "messages": messageData,
      "message_history": message
    };
    // Convert the data to JSON
    String jsonData = jsonEncode(data);
    String serverUrl = Data.serverurl;

    var response = await http.post(
      Uri.parse(serverUrl.toString()),
      headers: {'Content-Type': 'application/json'},
      body: jsonData,
    );
    return response;
  }

  post_process_data(String response) async {
    var completionMemory = jsonDecode(response);
    Map<String, dynamic> responseData = {};
    print(completionMemory);
    if (completionMemory['videos'] != null) {
      responseData = Map<String, dynamic>.from(completionMemory['videos']);
    }
    if (completionMemory['notification']['title'] != null &&
        completionMemory['notification']['title'] != '') {
      Data.notification_title =
          jsonDecode(completionMemory['notification']['title']);
      Data.notification_body =
          jsonDecode(completionMemory['notification']['message']);
    }
    Data.completion_message = '';
    for (var message in completionMemory['reply']) {
      final mentorMessage = types.TextMessage(
        author: types.User(id: 'mentor'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: Data.uuid.v1(),
        text: message,
      );
      Data.completion_message += message;
      Data.messages_data.insert(0, mentorMessage);
    }
    Loader loader = Loader();
    loader.saveMessages(Data.messages_data);
    loader.saveMessageHistory(completionMemory['message_history']);
    loader.savecompletion(Data.completion_message);

    Data.videoList = (responseData)
        .entries
        .map((entry) => Video.fromJson({
              'title': entry.key,
              'videoId': entry.value[0],
              'videoDescription': entry.value[1],
            }))
        .toList();
    if (Data.videoList != []) {
      loader.saveVideoList();
    }
  }

  execute([String interest = ""]) async {
    String messageData = await _preparing_data(interest);
    http.Response response = await meet_with_server(messageData);
    if (response.statusCode == 200) {
      post_process_data(response.body);
    } else {
      Data.completion_message = 'Error: ${response.statusCode}';
    }
  }

  Future<List<Map<String, dynamic>>> getJournalData(String userId) async {
    List<QueryDocumentSnapshot> documents = await Loader.loadjournal();
    List<Map<String, dynamic>> journalDataList = documents.map((doc) {
      // Extract the date from the Timestamp
      DateTime date = (doc['title'] as Timestamp).toDate();
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Create a new map without the userId field
      Map<String, dynamic> newData =
          Map.from(doc.data() as Map<dynamic, dynamic>)..remove('userId');

      // Set the 'title' field to the formatted date
      newData['title'] = formattedDate;

      return newData;
    }).toList();
    return journalDataList;
  }
}

class HabiticaData {
  late String user_id;
  late String api_key;
  late Uri api_url;
  late http.Client habitica_session;
  late List<List<dynamic>> csv_file;
  late Map<String, String> header;

  HabiticaData(this.user_id, this.api_key) {
    api_url = Uri.parse('https://habitica.com/api/v3');
    habitica_session = http.Client();
    header = {
      "x-api-user": user_id,
      "x-api-key": api_key,
      "Content-Type": "application/json"
    };
  }

  static Future<bool> testHabiticaAPI(String userId, String apiKey) async {
    final response = await http.get(
      Uri.parse('https://habitica.com/api/v3/user'),
      headers: {
        'x-api-user': userId,
        'x-api-key': apiKey,
      },
    );
    if (response.statusCode == 200) {
      // API key and user ID are valid
      return true;
    } else {
      // API key or user ID is invalid
      return false;
    }
  }

  List<List<String>> convertToNestedList(String input) {
    List<List<String>> nestedList = [];
    List<String> lines =
        input.replaceAll('[', '').replaceAll(']', '').split('\n');

    for (int i = 0; i < lines.length; i++) {
      List<String> values = lines[i].split(', ');
      nestedList.add(values);
    }

    return nestedList;
  }

  Future<List<List<dynamic>>> getUserData() async {
    final response = await habitica_session.get(
        Uri.parse('https://habitica.com/export/history.csv'),
        headers: header);

    if (response.statusCode != 200) {
      throw Exception('Failed to load user data: ${response.statusCode}');
    }
    final csvData = response.body;
    List<List<dynamic>> csvFile = const CsvToListConverter().convert(csvData);
    csvFile = convertToNestedList(csvFile.toString());
    // Remove header row
    csvFile.removeAt(0);
    // Remove unwanted columns (Task ID, Task Type, Value)
    csvFile = csvFile.map((row) => [row[0], row[3]]).toList();

    //Sort by date in ascending order
    csvFile.sort((a, b) => DateTime.parse(a[1] as String)
        .compareTo(DateTime.parse(b[1] as String)));

    csv_file = csvFile;

    return csv_file;
  }

  List<List<dynamic>> getDate(String targetDate) {
    final filteredData = csv_file
        .where((row) => (row[1] as String).startsWith(targetDate))
        .toList();
    return filteredData;
  }

  List getPastDates(String targetDateString, int numDays) {
    final targetDate = DateFormat('yyyy-MM-dd').parse(targetDateString);
    final startDate = targetDate.subtract(Duration(days: numDays));

    final filteredData = csv_file.where((row) {
      final rowDate = DateFormat('yyyy-MM-dd').parse(row[1] as String);
      return rowDate.isAfter(startDate);
    }).toList();
    return filteredData;
  }

  Future<String> execute({String? target_date, int num_days = 1}) async {
    String result = '';
    target_date ??= DateFormat('yyyy-MM-dd').format(DateTime.now());
    await getUserData();
    final habiticaData = getPastDates(target_date, num_days);
    // Append the item to the result string
    for (var item in habiticaData) {
      result += '\n';
      for (var i in item) {
        result += i.toString();
        result += ' ';
      }
    }

    return result;
  }
}

class PhoneUsage {
  Future<String> getUsage() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 1));
    String outputString = "";

    outputString = await getUsageStats(startDate, endDate);

    return outputString;
  }

  static Future<void> showPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission for tracking your phone usage'),
          content: const Text(
              'Mentor needs permission to track your phone usage to understand you. This data is not stored.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                UsageStats.grantUsagePermission();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> getUsageStats(DateTime startDate, DateTime endDate) async {
    String outputString = "";
    List<UsageInfo> usageStats =
        await UsageStats.queryUsageStats(startDate, endDate);
    if (usageStats.isNotEmpty) {
      for (UsageInfo appUsage in usageStats) {
        if (int.parse(appUsage.totalTimeInForeground!) > 0) {
          Duration duration = Duration(
              milliseconds:
                  int.parse(appUsage.totalTimeInForeground.toString()));
          int hours = duration.inHours;
          int minutes = duration.inMinutes.remainder(60);
          if (hours > 0 || minutes > 0) {
            outputString += 'Package name: ${appUsage.packageName} ';
            outputString +=
                'Total time in foreground: $hours hours $minutes minutes\n';
          }
        }
      }
    }
    return outputString;
  }
}
