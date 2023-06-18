import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import '../home/home_page.dart';
import '../journal/journal_page.dart';
import '../setup/authentication_page.dart';
import 'habitica_integration_page.dart'; // New page for Habitica integration
import 'package:firebase_auth/firebase_auth.dart';
import 'tellusmore_page.dart';
import 'apps_selection_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 2;
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();

  final TextEditingController _serverurlController = TextEditingController();

  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      // Retrieve the input values
      String serverurl = _serverurlController.text;

      // Encrypt and save the data locally
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
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    String? serverurl = await _storage.read(key: 'server_url');

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
                  TextFormField(
                    controller: _serverurlController,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 50, 204, 102)),
                    decoration: const InputDecoration(
                      labelText: 'ServerUrl',
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 50, 204, 102)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 50, 204, 102)),
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
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 50, 204, 102),
                    ),
                    child: const Text('Save'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppSelectionPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 50, 204, 102),
                    ),
                    child: const Text('Edit your home screen apps'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Knowingthestudent(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 50, 204, 102),
                    ),
                    child: const Text('Edit your goal and purpose'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabiticaIntegrationPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 50, 204, 102),
                    ),
                    child: const Text('Connect with Habitica'),
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
                            builder: (context) => EmailAuth(),
                          ),
                        );
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
              icon: Icon(Icons.book),
              label: 'Journal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color.fromARGB(255, 50, 204, 102),
          unselectedItemColor: Colors.white,
          backgroundColor: Colors.black,
          onTap: (int index) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MentorPage(),
                  ),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JournalPage(),
                  ),
                );
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ),
                );
                break;
            }
          },
        ),
      ),
    );
  }
}
