import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Knowingthestudent extends StatefulWidget {
  const Knowingthestudent({Key? key}) : super(key: key);

  @override
  State<Knowingthestudent> createState() => _KnowingthestudentState();
}

class _KnowingthestudentState extends State<Knowingthestudent> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();
  String userGoal = '';
  String selfPerception = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    String? loadedUserGoal = await storage.read(key: 'userGoal');
    String? loadedSelfPerception = await storage.read(key: 'selfPerception');

    if (loadedUserGoal != null) {
      setState(() {
        userGoal = loadedUserGoal;
      });
    }

    if (loadedSelfPerception != null) {
      setState(() {
        selfPerception = loadedSelfPerception;
      });
    }
  }

  void saveUserData() async {
    if (_formKey.currentState!.validate()) {
      await storage.write(key: 'userGoal', value: userGoal);
      await storage.write(key: 'selfPerception', value: selfPerception);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Got it!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mentor/FirstMeet',
          style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              "What is your goal or your purpose?",
              style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
            ),
            const SizedBox(height: 10),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'To Guide you to it';
                }
                return null; // Return null if the value is valid
              },
              style: const TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 19, 19, 19),
                labelText: 'Your Goal',
                labelStyle: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
              ),
              onChanged: (value) {
                setState(() {
                  userGoal = value;
                });
              },
              initialValue: userGoal, // Set the initial value
            ),
            const SizedBox(height: 16),
            const Text(
              "What do you think about yourself?",
              style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
            ),
            const SizedBox(height: 10),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This is used to know your current mental state';
                }
                return null; // Return null if the value is valid
              },
              style: const TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 19, 19, 19),
                labelText: 'Self-Perception',
                labelStyle: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
              ),
              onChanged: (value) {
                setState(() {
                  selfPerception = value;
                });
              },
              initialValue: selfPerception, // Set the initial value
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveUserData,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
