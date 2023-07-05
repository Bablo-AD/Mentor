import 'package:flutter/material.dart';

import '../core/loader.dart';
import '../core/widget.dart';

class Knowingthestudent extends StatefulWidget {
  const Knowingthestudent({Key? key}) : super(key: key);

  @override
  State<Knowingthestudent> createState() => _KnowingthestudentState();
}

class _KnowingthestudentState extends State<Knowingthestudent> {
  Loader _loader = Loader();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userGoalController = TextEditingController();
  final TextEditingController _selfPerceptionController =
      TextEditingController();
  String userGoal = '';
  String selfPerception = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    Map<String, String?> user_stuff = await _loader.load_user_stuff();

    String? loadedUserGoal = user_stuff['userGoal'];
    String? loadedSelfPerception = user_stuff['selfPerception'];

    if (loadedUserGoal != null) {
      setState(() {
        userGoal = loadedUserGoal;
        _userGoalController.text = userGoal; // Set the text in the controller
      });
    }

    if (loadedSelfPerception != null) {
      setState(() {
        selfPerception = loadedSelfPerception;
        _selfPerceptionController.text =
            selfPerception; // Set the text in the controller
      });
    }
  }

  void saveUserData() async {
    if (_formKey.currentState!.validate()) {
      _loader.save_user_stuff(
          _userGoalController.text, _selfPerceptionController.text);
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
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CoreText(text: 'What is your goal or purpose?'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _userGoalController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'To Guide you to it';
                    }
                    return null; // Return null if the value is valid
                  },
                  style:
                      const TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 19, 19, 19),
                    labelText: 'Your Goal',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      userGoal = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const CoreText(
                  text: "What do you think about yourself?",
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _selfPerceptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This is used to know your current mental state';
                    }
                    return null; // Return null if the value is valid
                  },
                  style:
                      const TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 19, 19, 19),
                    labelText: 'Self-Perception',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selfPerception = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CoreElevatedButton(label: 'Save', onPressed: saveUserData)
              ],
            ),
          ),
        )));
  }
}
