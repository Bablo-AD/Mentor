import 'package:flutter/material.dart';

import '../../utils/loader.dart';

class Knowingthestudent extends StatefulWidget {
  const Knowingthestudent({Key? key}) : super(key: key);

  @override
  State<Knowingthestudent> createState() => _KnowingthestudentState();
}

class _KnowingthestudentState extends State<Knowingthestudent> {
  final Loader _loader = Loader();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userGoalController = TextEditingController();
  final TextEditingController _selfPerceptionController =
      TextEditingController();
  final TextEditingController _shortTermGoalController =
      TextEditingController();
  String shortTermGoal = '';
  String userGoal = '';
  String selfPerception = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    Map<String, String?> userStuff = await _loader.load_user_stuff();

    String loadedUserGoal = userStuff['userGoal'] ?? "";
    String loadedSelfPerception = userStuff['selfPerception'] ?? "";
    String loadedShortTermGoal = userStuff['shortTermGoal'] ?? "";
    setState(() {
      userGoal = loadedUserGoal;
      _userGoalController.text = userGoal;
      selfPerception = loadedSelfPerception;
      _selfPerceptionController.text =
          selfPerception; // Set the text in the controller
      shortTermGoal = loadedShortTermGoal;
      _shortTermGoalController.text = shortTermGoal;
    });
  }

  void saveUserData() async {
    if (_formKey.currentState!.validate()) {
      _loader.save_user_stuff(_userGoalController.text,
          _selfPerceptionController.text, _shortTermGoalController.text);
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
            'Tell me about yourself',
          ),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('What is your short term goal?'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _shortTermGoalController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your short term goal';
                    }
                    return null; // Return null if the value is valid
                  },
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Your Short Term Goal',
                  ),
                  onChanged: (value) {
                    setState(() {
                      shortTermGoal = value;
                    });
                  },
                ),
                const Text('What is your current goal or purpose?'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _userGoalController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'What are you trying to achieve';
                    }
                    return null; // Return null if the value is valid
                  },
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Your Long Term Goal',
                  ),
                  onChanged: (value) {
                    setState(() {
                      userGoal = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  "Tell me about yourself.",
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _selfPerceptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This is used to know your current workable factor';
                    }
                    return null; // Return null if the value is valid
                  },
                  maxLines: null,
                  minLines: 3,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'About You',
                  ),
                  onChanged: (value) {
                    setState(() {
                      selfPerception = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: saveUserData, child: const Text('Save'))
              ],
            ),
          ),
        )));
  }
}
