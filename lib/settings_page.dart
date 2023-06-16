import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import 'journal_page.dart';
import 'authentication_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 2;
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();

  final TextEditingController _habiticaUserIdController =
      TextEditingController();
  final TextEditingController _habiticaApiKeyController =
      TextEditingController();
  final TextEditingController _serverurlController = TextEditingController();

  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      // Retrieve the input values
      String habiticaUserId = _habiticaUserIdController.text;
      String habiticaApiKey = _habiticaApiKeyController.text;
      String serverurl = _serverurlController.text;

      // Encrypt and save the data locally
      await _storage.write(
        key: 'habitica_user_id',
        value: habiticaUserId,
      );
      await _storage.write(
        key: 'habitica_api_key',
        value: habiticaApiKey,
      );
      await _storage.write(
        key: 'server_url',
        value: serverurl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Got it!')),
      );
    }
  }

  @override
  void dispose() {
    _habiticaUserIdController.dispose();
    _habiticaApiKeyController.dispose();
    _serverurlController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    String? habiticaUserId = await _storage.read(key: 'habitica_user_id');
    String? habiticaApiKey = await _storage.read(key: 'habitica_api_key');
    String? serverurl = await _storage.read(key: 'server_url');

    _habiticaUserIdController.text = habiticaUserId ?? '';
    _habiticaApiKeyController.text = habiticaApiKey ?? '';

    _serverurlController.text =
        serverurl ?? 'https://prasannanrobots.pythonanywhere.com/mentor';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.black,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Mentor/Settings',
                style: TextStyle(color: Colors.green),
              ),
              backgroundColor: Colors.black,
            ),
            backgroundColor: Colors.black,
            body: SingleChildScrollView(
              // Wrap the body with SingleChildScrollView
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _serverurlController,
                        style: const TextStyle(color: Colors.green),
                        decoration: const InputDecoration(
                          labelText: 'ServerUrl',
                          labelStyle: TextStyle(color: Colors.green),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
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
                      TextFormField(
                        controller: _habiticaUserIdController,
                        style: const TextStyle(color: Colors.green),
                        decoration: const InputDecoration(
                          labelText: 'Habitica User ID',
                          labelStyle: TextStyle(color: Colors.green),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a valid Habitica User ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _habiticaApiKeyController,
                        style: const TextStyle(color: Colors.green),
                        decoration: const InputDecoration(
                          labelText: 'Habitica API Key',
                          labelStyle: TextStyle(color: Colors.green),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a valid Habitica API Key';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Save'),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                              context); // Go back to the previous page
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Go Back'),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          await SessionManager.saveLoginState(false);
                          setState(() {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EmailAuth()));
                          });
                          // Additional code after successful sign-out
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notes),
                  label: 'Journal',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.white,
              backgroundColor: Colors.black,
              onTap: (int index) {
                switch (index) {
                  case 0:
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MentorPage()));
                    break;
                  case 1:
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => JournalPage()));
                    break;
                  case 2:
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsPage()));
                    break;
                }
              },
            )));
  }
}
