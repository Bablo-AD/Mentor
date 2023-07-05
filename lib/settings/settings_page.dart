import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/loader.dart';
import '../core/widget.dart';
import '../setup/authentication_page.dart';

import 'auto_request.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final int _selectedIndex = 2;
  final _formKey = GlobalKey<FormState>();
  final _loader = Loader();

  final TextEditingController _serverurlController = TextEditingController();

  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      // Retrieve the input values
      _loader.saveserverurl(_serverurlController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Got it!')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    _serverurlController.text = await _loader.loadserverurl();
  }

  @override
  Widget build(BuildContext context) {
    return CoreScaffold(
      title: "Mentor/Settings",
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _serverurlController,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                  decoration: const InputDecoration(
                    labelText: 'ServerUrl',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 50, 204, 102)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 50, 204, 102)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid Url';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                CoreElevatedButton(onPressed: _saveSettings, label: "Save"),
                const SizedBox(height: 16.0),
                CoreElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/appSelectionPage');
                    },
                    label: "Edit YOur Home Screen Apps"),
                const SizedBox(height: 16.0),
                CoreElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AutoRequest(),
                        ),
                      );
                    },
                    label: "AutoMentor"),
                const SizedBox(height: 16.0),
                CoreElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/knowingthestudent');
                    },
                    label: "Edit your goal and purpose"),
                const SizedBox(height: 16.0),
                CoreElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/habiticaIntegrationPage');
                    },
                    label: "Connect with Habitica"),
                const SizedBox(height: 16.0),
                CoreElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    await SessionManager.saveLoginState(false);
                    setState(() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmailAuth(),
                        ),
                      );
                    });
                    // Additional code after successful sign-out
                  },
                  bgcolor: Colors.red,
                  label: 'Sign Out',
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CoreBottomNavigationBar(
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
