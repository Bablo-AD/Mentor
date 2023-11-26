import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../home/make_request.dart';
import '../core/loader.dart';

class AutoRequest extends StatefulWidget {
  const AutoRequest({super.key});

  @override
  State<AutoRequest> createState() => _AutoRequestState();
}

class _AutoRequestState extends State<AutoRequest> {
  late SharedPreferences sharedPreferences;
  final Loader _loader = Loader();
  TimeOfDay default_time = TimeOfDay.now();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    _loadScheduledTime();
  }

  void _loadScheduledTime() async {
    String? scheduledTime = await _loader.loadScheduledTime();
    if (scheduledTime != null) {
      if (mounted) {
        setState(() {
          final parsedTime =
              TimeOfDay.fromDateTime(DateTime.parse(scheduledTime));
          default_time = parsedTime;
        });
      }
    }
  }

  void _saveScheduledTime(TimeOfDay selectedTime) async {
    final dateTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, selectedTime.hour, selectedTime.minute);
    final formattedTime = dateTime.toIso8601String();
    _loader.saveScheduleTime(formattedTime);
  }

  void _scheduleBackgroundTask(TimeOfDay scheduledTime) async {
    DateTime scheduledDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
    if (DateTime.now().isAfter(scheduledDateTime!)) {
      scheduledDateTime = scheduledDateTime!.add(Duration(days: 1));
    }

    Duration delay = scheduledDateTime!.difference(DateTime.now());

    Workmanager().registerPeriodicTask(
      '1',
      'dailyanalysis',
      frequency: Duration(days: 1), // Repeat every 24 hours
      initialDelay: delay, // Delay until the next specified time
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Background task scheduled at $scheduledTime'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mentor/Settings/Auto_Request',
          ),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  showTimePicker(
                    context: context,
                    initialTime: default_time,
                  ).then((selectedTime) async {
                    if (selectedTime != null) {
                      _saveScheduledTime(selectedTime);
                      _scheduleBackgroundTask(selectedTime);
                      // DataProcessor processor = DataProcessor(context);
                      // ScheduleManager(callback: processor.execute);
                    }
                  });
                },
                child: const Text('Set Scheduled Time',
                    style: TextStyle(color: Color.fromARGB(255, 50, 204, 102))),
              ),
            ],
          ),
        )));
  }
}

class ScheduleManager {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static void showNotification(String message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name',
        importance: Importance.max, priority: Priority.high, showWhen: false);
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Your day analysis',
      message,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  static void backgroundTask(BuildContext context) async {
    String result;
    try {
      DataProcessor dataGetter = DataProcessor(context);
      result = await dataGetter.execute();
    } catch (e) {
      result = e.toString();
    }
    showNotification(result);
  }

  @pragma('vm:entry-point')
  static void callbackDispatcher(BuildContext context) {
    Workmanager().executeTask((task, inputData) {
      backgroundTask(context);
      return Future.value(true);
    });
  }
}

// class ScheduleManager {
//   final VoidCallback callback;
//   late TimeOfDay scheduledTime;
//   late Timer _timer;

//   ScheduleManager({required this.callback});

//   void scheduleEmulateRequest(TimeOfDay desiredTime) {
//     // Cancel any existing timer
//     _cancelTimer();

//     // Set the desired time for scheduling
//     scheduledTime = desiredTime;

//     // Start the timer to schedule the callback at the desired time
//     _startTimer();
//   }

//   void _startTimer() {
//     final now = DateTime.now();
//     final scheduledDateTime = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       scheduledTime.hour,
//       scheduledTime.minute,
//     );

//     // Calculate the duration until the desired time
//     Duration duration;
//     if (scheduledDateTime.isBefore(now)) {
//       final tomorrow = DateTime(now.year, now.month, now.day + 1);
//       duration = scheduledDateTime.difference(now) + tomorrow.difference(now);
//     } else {
//       duration = scheduledDateTime.difference(now);
//     }

//     // Schedule the callback to be called after the duration
//     _timer = Timer(duration, callback);
//   }

//   void _cancelTimer() {
//     if (_timer.isActive) {
//       _timer.cancel();
//     }
//   }
// }
