import 'package:Mentor/core/loader.dart';
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';


class PreferredTimePage extends StatefulWidget {
  const PreferredTimePage({super.key});

  @override
  _PreferredTimePageState createState() => _PreferredTimePageState();
}

class _PreferredTimePageState extends State<PreferredTimePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Select Preferred Time'),
        ),
        body: const PreferredTimeSelection());
  }
}

class PreferredTimeSelection extends StatefulWidget {
  const PreferredTimeSelection({super.key});

  @override
  _PreferredTimeSelectionState createState() => _PreferredTimeSelectionState();
}

class _PreferredTimeSelectionState extends State<PreferredTimeSelection> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  final Loader _loader = Loader();

  @override
  void initState() {
    super.initState();

    _loader.getSelectedTime().then((time) {
      setState(() {
        _selectedTime = time ?? TimeOfDay.now();
      });
    });
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
      await _loader.saveSelectedTime(pickedTime);
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
        Loader.makerequest,
        startAt: initialAlarmDateTime,
        exact: true,
        wakeup: true,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preference set as ${_selectedTime.format(context)}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Select your preferred time to reflect back and improve. Your AI mentor will evaluate and provide feedback...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),
          const Text(
            'Preferred Time:',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            _selectedTime.format(context),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _selectTime(context),
            child: const Text('Select Time'),
          ),
        ],
      ),
    );
  }
}
