import 'package:flutter/material.dart';
import '../../utils/data.dart';
import '../../utils/loader.dart';

class EmailSettingsPage extends StatefulWidget {
  const EmailSettingsPage({super.key});

  @override
  _EmailSettingsPageState createState() => _EmailSettingsPageState();
}

class _EmailSettingsPageState extends State<EmailSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  Loader loademail = Loader();

  void _saveEmail() {
    if (_formKey.currentState?.validate() ?? false) {
      // Save email to Firebase
      String email = _emailController.text;
      // Add your Firebase code here to save the email address
      loademail.save_parents_email(email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email saved successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    loademail
        .load_parents_email()
        .then((email) => _emailController.text = email.toString());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor/Parental Controls'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Enter your email address to receive notifications about your child\'s behavior.',
                style:
                    TextStyle(fontSize: 16), // Adjust the text style as needed
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? false) {
                    return 'Please enter an email address';
                  }
                  if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                      .hasMatch(value ?? '')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveEmail,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
