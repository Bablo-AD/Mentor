import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();

  final TextEditingController _habiticaUserIdController =
      TextEditingController();
  final TextEditingController _habiticaApiKeyController =
      TextEditingController();
  final TextEditingController _googleKeepEmailController =
      TextEditingController();
  final TextEditingController _googleKeepPasswordController =
      TextEditingController();
  final TextEditingController _serverurlController = TextEditingController();

  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      // Retrieve the input values
      String habiticaUserId = _habiticaUserIdController.text;
      String habiticaApiKey = _habiticaApiKeyController.text;
      String googleKeepEmail = _googleKeepEmailController.text;
      String googleKeepPassword = _googleKeepPasswordController.text;
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
        key: 'google_keep_email',
        value: googleKeepEmail,
      );
      await _storage.write(
        key: 'google_keep_password',
        value: googleKeepPassword,
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
    _googleKeepEmailController.dispose();
    _googleKeepPasswordController.dispose();
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
    String? googleKeepEmail = await _storage.read(key: 'google_keep_email');
    String? googleKeepPassword =
        await _storage.read(key: 'google_keep_password');
    String? serverurl = await _storage.read(key: 'server_url');

    _habiticaUserIdController.text = habiticaUserId ?? '';
    _habiticaApiKeyController.text = habiticaApiKey ?? '';
    _googleKeepEmailController.text = googleKeepEmail ?? '';
    _googleKeepPasswordController.text = googleKeepPassword ?? '';
    _serverurlController.text = serverurl ?? '';
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
            title: const Text('Mentor/Settings'),
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
                    TextFormField(
                      controller: _googleKeepEmailController,
                      style: const TextStyle(color: Colors.green),
                      decoration: const InputDecoration(
                        labelText: 'Google Keep Email',
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
                          return 'Please enter a valid Google Keep Email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _googleKeepPasswordController,
                      style: const TextStyle(color: Colors.green),
                      decoration: const InputDecoration(
                        labelText: 'Google Keep Password',
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
                          return 'Please enter a valid Google Keep Password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
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
                        Navigator.pop(context); // Go back to the previous page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
