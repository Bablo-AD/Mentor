import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:usage_stats/usage_stats.dart';

import 'dart:convert';
import 'dart:io';

import '../core/loader.dart';
import '../core/data.dart';

class DataProcessor {
  final _loader = Loader();

  late BuildContext context;
  DataProcessor(BuildContext context);

  //Processes the request to be sent to the server
  Future<String> _preparing_data(String interest) async {
    String habits = '';
    String phoneUsageData = '';

    //Preparing Habitica Data
    Map<String, String?> details = await _loader.loadHabiticaDetails();
    String? userId = details['userId'];
    String? apiKey = details['apiKey'];
    if (userId != null && apiKey != null) {
      HabiticaData habiticaData = HabiticaData(userId, apiKey);
      habits = await habiticaData.execute();
    }

    //Preparing phone usage data
    if (Platform.isAndroid) {
      PhoneUsage phoneUsage = PhoneUsage();
      phoneUsageData = phoneUsage.getUsage(context).toString();
    }

    //Preparing journal Data
    String journalDataList =
        await getJournalData(Data.userId.toString()).toString();

    //Preparing usergoal,self perception
    Map<String, String?> userStuff = await _loader.load_user_stuff();
    String usergoal = userStuff['userGoal'].toString();
    String selfperception = userStuff['selfPerception'].toString();
    // Prepare the data to send in the request
    String meta_data = """habits= $habits,
      goal= $interest,
      journal= $journalDataList,
      usage= $phoneUsageData,
      usergoal= $usergoal,
      selfperception= $selfperception""";

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(userId).get();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    Map<String, String> data = {
      "messages": meta_data,
      "user_id": Data.userId.toString(),
      "apikey": userData['apikey'],
      "update_history": "True"
    };

    // Convert the data to JSON
    String jsonData = jsonEncode(data);
    return jsonData;
  }

  Future<String> _meet_with_server(String jsonData) async {
    String serverUrl = await _loader.loadserverurl();

    var response = await http.post(
      Uri.parse(serverUrl.toString()),
      headers: {'Content-Type': 'application/json'},
      body: jsonData,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw 'Status code ${response.statusCode}';
    }
  }

  post_process_data(String response) async {
    var completionMemory = jsonDecode(response);
    Map<String, dynamic> responseData = completionMemory['videos'];
    Data.completion_message = completionMemory['completion'].toString();
    Data.messages_data
        .add(Messages(role: 'assistant', content: Data.completion_message));
    Data.videoList = (responseData)
        .entries
        .map((entry) => Video.fromJson({
              'title': entry.key,
              'videoId': entry.value[0],
              'videoDescription': entry.value[1],
            }))
        .toList();
  }

  execute([String interest = ""]) async {
    String jsonData = await _preparing_data(interest);
    String response = await _meet_with_server(jsonData);
    post_process_data(response);
  }
}

Future<List<Map<String, dynamic>>> getJournalData(String userId) async {
  List<QueryDocumentSnapshot> documents = await Loader.loadjournal();
  List<Map<String, dynamic>> journalDataList = documents.map((doc) {
    // Extract the date from the Timestamp
    DateTime date = (doc['title'] as Timestamp).toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // Create a new map without the userId field
    Map<String, dynamic> newData = Map.from(doc.data() as Map<dynamic, dynamic>)
      ..remove('userId');

    // Set the 'title' field to the formatted date
    newData['title'] = formattedDate;

    return newData;
  }).toList();
  return journalDataList;
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

  Future<String> execute({String? target_date, int num_days = 5}) async {
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
  Future<String> getUsage(BuildContext context) async {
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 3));
    String outputString = "";

    // check if permission is granted
    bool? isPermission = await UsageStats.checkUsagePermission();
    if (isPermission == false) {
      await _showPermissionDialog(context);
      isPermission = await UsageStats.checkUsagePermission();
    }

    if (isPermission == true) {
      outputString = await _getUsageStats(startDate, endDate);
    }

    return outputString;
  }

  Future<void> _showPermissionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'Please grant the usage permission to track app usage.'),
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

  Future<String> _getUsageStats(DateTime startDate, DateTime endDate) async {
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
