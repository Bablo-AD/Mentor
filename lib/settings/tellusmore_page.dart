import 'package:Bablo/journal/journal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Knowingthestudent extends StatefulWidget {
  const Knowingthestudent({Key? key}) : super(key: key);

  @override
  State<Knowingthestudent> createState() => _KnowingthestudentState();
}

class _KnowingthestudentState extends State<Knowingthestudent> {
  final _formKey = GlobalKey<FormState>();
  final storage = FlutterSecureStorage();
  String userGoal = '';
  String selfPerception = '';

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
            Text(
              "What is your goal or your purpose?",
              style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
            ),
            SizedBox(height: 10),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'To Guide you to it';
                }
                return null; // Return null if the value is valid
              },
              style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
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
            ),
            SizedBox(height: 16),
            Text(
              "What do you think about yourself?",
              style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
            ),
            SizedBox(height: 10),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This is used to know your current mental state';
                }
                return null; // Return null if the value is valid
              },
              style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
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
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveUserData,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
