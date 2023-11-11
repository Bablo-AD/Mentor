import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/loader.dart';
import '../setup/authentication_page.dart';

import 'auto_request.dart';
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
                  ElevatedButton(
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
                  const SizedBox(height: 4.0),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AutoRequest()));
                      },
                      child: Text("Select when you write journal")),
                  const SizedBox(height: 24.0),
                  Text("You", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 4.0),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/knowingthestudent');
                      },
                      child: Text("Edit your purpose")),
                  const SizedBox(height: 4),
                  OutlinedButton(
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
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/habiticaIntegrationPage');
                      },
                      child: Text("Connect with Habitica")),
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
