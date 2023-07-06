import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/loader.dart';

class AutoRequest extends StatefulWidget {
  const AutoRequest({super.key});

  @override
  State<AutoRequest> createState() => _AutoRequestState();
}

class _AutoRequestState extends State<AutoRequest> {
  late SharedPreferences sharedPreferences;
  Loader _loader = Loader();
  TimeOfDay default_time = TimeOfDay.now();
  @override
  void initState() {
    super.initState();
    _loadScheduledTime();
  }

  void _loadScheduledTime() async {
    String? scheduledTime = await _loader.loadScheduledTime();
    if (scheduledTime != null) {
      if (this.mounted) {
        setState(() {
          final parsedTime =
              TimeOfDay.fromDateTime(DateTime.parse(scheduledTime));
          default_time = parsedTime;
        });
      }
    }

    void _saveScheduledTime(TimeOfDay selectedTime) async {
      final dateTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, selectedTime.hour, selectedTime.minute);
      final formattedTime = dateTime.toIso8601String();
      await sharedPreferences.setString('scheduledTime', formattedTime);
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Mentor/Settings/Auto_Request',
              style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
            ),
            backgroundColor: Colors.black,
          ),
          backgroundColor: Colors.black,
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
                    ).then((selectedTime) {
                      if (selectedTime != null) {
                        _saveScheduledTime(selectedTime);
                      }
                    });
                  },
                  child: Text('Set Scheduled Time',
                      style:
                          TextStyle(color: Color.fromARGB(255, 50, 204, 102))),
                ),
              ],
            ),
          )));
    }
  }
}

class ScheduleManager {
  final VoidCallback callback;
  late TimeOfDay scheduledTime;
  late Timer _timer;

  ScheduleManager({required this.callback});

  void scheduleEmulateRequest(TimeOfDay desiredTime) {
    // Cancel any existing timer
    _cancelTimer();

    // Set the desired time for scheduling
    scheduledTime = desiredTime;

    // Start the timer to schedule the callback at the desired time
    _startTimer();
  }

  void _startTimer() {
    final currentTime = TimeOfDay.now();
    final now = DateTime.now();
    final scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    // Calculate the duration until the desired time
    Duration duration;
    if (scheduledDateTime.isBefore(now)) {
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      duration = scheduledDateTime.difference(now) + tomorrow.difference(now);
    } else {
      duration = scheduledDateTime.difference(now);
    }

    // Schedule the callback to be called after the duration
    _timer = Timer(duration, callback);
  }

  void _cancelTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
  }
}
