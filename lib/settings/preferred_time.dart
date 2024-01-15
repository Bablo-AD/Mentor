import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../home/make_request.dart';
import '../core/notifications.dart';
import '../core/data.dart';

class PreferredTimePage extends StatefulWidget {
  @override
  _PreferredTimePageState createState() => _PreferredTimePageState();
}

class _PreferredTimePageState extends State<PreferredTimePage> {
  late TimeOfDay _selectedTime;
  LocalNotificationService notifier = LocalNotificationService();

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay.now();
  }

  @pragma('vm:entry-point')
  void makerequest() async {
    DataProcessor dataGetter = DataProcessor();
    try {
      await dataGetter.execute();
    } catch (e) {
      print(e);
    }
    notifier.showNotificationAndroid('Daily Report', Data.completion_message);
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
      final now = DateTime.now();
      final initialAlarmDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await AndroidAlarmManager.periodic(
        const Duration(days: 1),
        0, // This is the alarm ID
        makerequest,
        startAt: initialAlarmDateTime,
        exact: true,
        wakeup: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Preferred Time'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Preferred Time:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '${_selectedTime.format(context)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text('Select Time'),
            ),
          ],
        ),
      ),
    );
  }
}
