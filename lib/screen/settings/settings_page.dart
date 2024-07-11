import 'package:Mentor/utils/data.dart';
import 'package:flutter/material.dart';

import '../../utils/loader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'parent_mode.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool get wantKeepAlive => true;
  int _selectedIndex = 2;
  final _formKey = GlobalKey<FormState>();
  final _loader = Loader();

  final TextEditingController _serverurlController = TextEditingController();
  String _version = '';

  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      // Retrieve the input values
      Data.apikey = _serverurlController.text;
      _loader.storeApiKey();

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
    _serverurlController.text = Data.serverurl;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mentor/Settings")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("About You", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 4.0),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(
                            16) // Adjust this value to suit your needs
                        ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/knowingthestudent');
                    },
                    child: const Text("Edit your purpose")),
                const SizedBox(height: 10),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(
                            16) // Adjust this value to suit your needs
                        ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/preferredtime');
                    },
                    child: const Text("Edit your preferred time")),
                const SizedBox(height: 24.0),
                const Text("Integrations", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 4.0),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10)), // Adjust this value to suit your needs
                        padding: const EdgeInsets.all(16)),
                    onPressed: () {
                      Navigator.pushNamed(context, '/habiticaIntegrationPage');
                    },
                    child: const Text("Connect with Habitica")),
                const SizedBox(height: 24.0),
                const Text("General Settings", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 4),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(
                            16) // Adjust this value to suit your needs
                        ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/appsSelection');
                    },
                    child: const Text("Edit your selected apps")),
                const SizedBox(height: 10),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(
                            16) // Adjust this value to suit your needs
                        ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EmailSettingsPage()),
                      );
                    },
                    child: const Text("Parental controls")),
                const SizedBox(height: 10.0),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(
                            16) // Adjust this value to suit your needs
                        ),
                    child: const Text("Edit ServerUrl"),
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
                                          const Text(
                                              "Only do this when you know what you are doing"),
                                          OutlinedButton(
                                              child: const Text("Back"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              }),
                                          const SizedBox(height: 4.0),
                                          FilledButton(
                                              onPressed: () {
                                                _saveSettings();
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Save")),
                                        ])));
                          });
                    }),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(
                          16) // Adjust this value to suit your needs
                      ),
                  onPressed: () {
                    _loader.clearMessageHistory();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message history cleared!')),
                    );
                  },
                  child: const Text("Clear Message History"),
                ),
                const SizedBox(height: 24.0),
                const Text("Feedback & Errors", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 4.0),
                TextButton(
                    onPressed: () {
                      launch(
                          'https://forms.gle/gRyfXvFPdbyQGjp38'); // Replace with your Google Form URL
                    },
                    child: const Text("Submit feedback or report errors")),
                const SizedBox(
                  height: 10,
                ),
                Center(
                    child: Text("Version $_version.",
                        style: TextStyle(fontSize: 18))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
