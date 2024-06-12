import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/data.dart';
import '../utils/loader.dart';
import '../utils/widgets/common.dart';
import 'setup_roller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void initialize_user() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String apiKey = generateApiKey();
    Map<String, dynamic> data = {
      "head": [
        {
          "role": "system",
          "content":
              "Now you are the user's productivity partner who analyzes the user's pattern and helps him grow.Basically you are a life mentor. Here I provide you the details of the user"
        }
      ],
      "body": [],
    };
    String messages = jsonEncode(data);
    await firestore
        .collection('users')
        .doc(Data.userId.toString())
        .set({"apikey": apiKey, "messages": messages});
  }

  String generateApiKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    final apiKey = base64Url.encode(values);
    return apiKey;
  }

  Future<void> _signUp() async {
    // Validate email
    if (!_isValidEmail(_emailController.text.trim())) {
      _showErrorDialog('Invalid Email');
      return;
    }

    // Validate password
    if (!_isValidPassword(_passwordController.text.trim())) {
      _showErrorDialog('Invalid Password. Minimum 8 characters required.');
      return;
    }

    // Check if passwords match
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // User account creation successful
      User? user = userCredential.user;
      if (user != null) {
        Data.userId = user.uid;
        initialize_user();
        await SessionManager.saveLoginState(true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SetupPage()),
        );
      }
    } catch (e) {
      // Handle sign-up errors
      print('Sign-up error: $e');
      _showErrorDialog('Sign-up Failed. Please try again.');
    }
  }

  bool _isValidEmail(String email) {
    // Add your email validation logic here
    // You can use a regular expression or any other method
    return email.isNotEmpty;
  }

  bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mentor/Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Join the Jungle",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            buildTextField(_emailController, "Email"),
            const SizedBox(height: 5.0),
            buildTextField(_passwordController, "Password", obscureText: true),
            const SizedBox(height: 5.0),
            buildTextField(_confirmPasswordController, "Confirm Password",
                obscureText: true),
            const SizedBox(height: 30.0),
            FilledButton(
              onPressed: _signUp,
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
