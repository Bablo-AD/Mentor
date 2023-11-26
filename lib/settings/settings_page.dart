import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/loader.dart';
import '../setup/authentication_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 2;
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
    return Scaffold(
        appBar: AppBar(title: Text("Mentor/Settings")),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("About You", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 4.0),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(
                              16) // Adjust this value to suit your needs
                          ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/knowingthestudent');
                      },
                      child: Text("Edit your purpose")),
                  const SizedBox(height: 4),
                  OutlinedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(
                            16) // Adjust this value to suit your needs
                        ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      await SessionManager.saveLoginState(false);
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      await preferences.clear();
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
                    child: Text('Sign Out'),
                  ),
                  const SizedBox(height: 24.0),
                  Text("Integrations", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 4.0),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10)), // Adjust this value to suit your needs
                          padding: EdgeInsets.all(16)),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/habiticaIntegrationPage');
                      },
                      child: Text("Connect with Habitica")),
                  const SizedBox(height: 24.0),
                  Text("General Settings", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(
                              16) // Adjust this value to suit your needs
                          ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/appsSelection');
                      },
                      child: Text("Edit your selected apps")),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(
                              16) // Adjust this value to suit your needs
                          ),
                      child: Text("Edit ServerUrl"),
                      onPressed: () {
                        showDialog(
                            barrierDismissible: true,
                            barrierLabel: MaterialLocalizations.of(context)
                                .modalBarrierDismissLabel,
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog.fullscreen(
                                  child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            TextFormField(
                                              controller: _serverurlController,
                                              style: const TextStyle(),
                                              decoration: const InputDecoration(
                                                labelText: 'ServerUrl',
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(),
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
                                            Text(
                                                "Only do this when you know what you are doing"),
                                            OutlinedButton(
                                                child: Text("Back"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                }),
                                            const SizedBox(height: 4.0),
                                            FilledButton(
                                                onPressed: () {
                                                  _saveSettings();
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Save")),
                                          ])));
                            });
                      }),
                  const SizedBox(height: 24.0),
                  Text("Feedback & Errors", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 4.0),
                  TextButton(
                      onPressed: () {
                        launch(
                            'https://forms.gle/gRyfXvFPdbyQGjp38'); // Replace with your Google Form URL
                      },
                      child: Text("Submit feedback or report errors")),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/mentor');
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, '/journal');
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, '/settings');
                  break;
              }
            });
          },
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.book),
              label: 'Journal',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ));
  }
}
