import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class HabiticaIntegrationPage extends StatefulWidget {
  const HabiticaIntegrationPage({Key? key}) : super(key: key);

  @override
  _HabiticaIntegrationPageState createState() =>
      _HabiticaIntegrationPageState();
}

class _HabiticaIntegrationPageState extends State<HabiticaIntegrationPage> {
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _habiticaUserIdController = TextEditingController();
  TextEditingController _habiticaApiKeyController = TextEditingController();
  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      // Retrieve the input values
      String habiticaUserId = _habiticaUserIdController.text;
      String habiticaApiKey = _habiticaApiKeyController.text;

      // Test the API key and user ID
      bool isValid = await _testHabiticaAPI(habiticaUserId, habiticaApiKey);
      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Habitica API Key or User ID')),
        );
        return;
      }

      // Encrypt and save the data locally
      await _storage.write(
        key: 'habitica_user_id',
        value: habiticaUserId,
      );
      await _storage.write(
        key: 'habitica_api_key',
        value: habiticaApiKey,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key and User ID saved')),
      );
      Navigator.pop(context);
    }
  }

  Future<bool> _testHabiticaAPI(String userId, String apiKey) async {
    final response = await http.get(
      Uri.parse('https://habitica.com/api/v3/user'),
      headers: {
        'x-api-user': userId,
        'x-api-key': apiKey,
      },
    );
    if (response.statusCode == 200) {
      // API key and user ID are valid
      return true;
    } else {
      // API key or user ID is invalid
      return false;
    }
  }

  void _loadSettings() async {
    String? habiticaUserId = await _storage.read(key: 'habitica_user_id');
    String? habiticaApiKey = await _storage.read(key: 'habitica_api_key');
    _habiticaUserIdController.text = habiticaUserId ?? '';
    _habiticaApiKeyController.text = habiticaApiKey ?? '';
  }

  @override
  void dispose() {
    _habiticaUserIdController.dispose();
    _habiticaApiKeyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mentor/Settings/Habitica',
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
                Text(
                  'What is Habitica?',
                  style: TextStyle(
                    color: Color.fromARGB(255, 50, 204, 102),
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Habitica is a habit-tracking app that helps you improve your productivity and turn your tasks and goals into a game. To connect with Habitica, you need to provide your Habitica User ID and API Key.',
                  style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                ),
                const SizedBox(height: 16.0),
                Text(
                  "To find your API Token",
                  style: TextStyle(
                    color: Color.fromARGB(255, 50, 204, 102),
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '1. For the website: User Icon > Settings > API.',
                  style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '2. For iOS/Android App: Menu > API > API Token (tap on it to copy it to your clipboard).',
                  style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _habiticaUserIdController,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                  decoration: const InputDecoration(
                    labelText: 'Habitica User ID',
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
                      return 'Please enter a valid Habitica User ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _habiticaApiKeyController,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                  decoration: const InputDecoration(
                    labelText: 'Habitica API Key',
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
                      return 'Please enter a valid Habitica API Key';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _saveSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 50, 204, 102),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        )));
  }
}
