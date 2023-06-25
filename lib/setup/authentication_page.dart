import 'package:Bablo/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String loggedInKey = 'loggedIn';

  static Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loggedInKey, isLoggedIn);
  }

  static Future<bool> getLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loggedInKey) ?? false;
  }
}

class EmailAuth extends StatefulWidget {
  const EmailAuth({super.key});

  @override
  _EmailAuthState createState() => _EmailAuthState();
}

class _EmailAuthState extends State<EmailAuth> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  pushNextPage(user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', user);
    await SessionManager.saveLoginState(true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // User sign-in successful
      User? user = userCredential.user;
      if (user != null) {
        pushNextPage(user.uid);
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
        pushNextPage(user.uid);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mentor/Authentication',
          style: TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                style:
                    const TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 19, 19, 19),
                  labelText: 'Email',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _passwordController,
                style:
                    const TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 19, 19, 19),
                  labelText: 'Password',
                  labelStyle:
                      TextStyle(color: Color.fromARGB(255, 50, 204, 102)),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
