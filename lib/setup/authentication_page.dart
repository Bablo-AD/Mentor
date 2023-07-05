import '../core/widget.dart';
import '../core/loader.dart';
import 'setup_roller.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailAuth extends StatefulWidget {
  const EmailAuth({super.key});

  @override
  _EmailAuthState createState() => _EmailAuthState();
}

class _EmailAuthState extends State<EmailAuth> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // User sign-in successful
      User? user = userCredential.user;
      if (user != null) {
        await SessionManager.saveLoginState(true);
        Navigator.pushReplacementNamed(context, '/settings');
      }
    } catch (e) {
      // Handle sign-in errors
      print('Sign-in error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign-in Failed'),
            content: const Text('Invalid email or password.'),
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
  }

  Future<void> _signUp() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // User account creation successful
      User? user = userCredential.user;
      if (user != null) {
        await SessionManager.saveLoginState(true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SetupPage()),
        );
      }
    } catch (e) {
      // Handle sign-up errors
      print('Sign-up error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign-up Failed'),
            content: const Text('Please try again.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return CoreScaffold(
      title: 'Mentor/Authentication',
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CoreTextField(
                controller: _emailController,
                label: "Email",
              ),
              const SizedBox(height: 8.0),
              CoreTextField(
                controller: _passwordController,
                label: "Password",
              ),
              const SizedBox(height: 16.0),
              CoreElevatedButton(
                onPressed: _signIn,
                label: "Sign In",
              ),
              const SizedBox(height: 8.0),
              CoreElevatedButton(
                onPressed: _signUp,
                label: "Sign Up",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
