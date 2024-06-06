import '../utils/loader.dart';
import '../utils/data.dart';
import 'signup_page.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'setup_roller.dart';

class EmailAuth extends StatefulWidget {
  const EmailAuth({super.key});

  @override
  _EmailAuthState createState() => _EmailAuthState();
}

class _EmailAuthState extends State<EmailAuth> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential googleCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential googleAuthResult =
          await _auth.signInWithCredential(googleCredential);
      final User? googleUser = googleAuthResult.user;

      if (googleUser != null) {
        final User? currentUser = _auth.currentUser;

        if (currentUser != null && currentUser.email == googleUser.email) {
          // The user has already signed up with the same email id
          try {
            // Try to link the Google account to the existing account
            await currentUser.linkWithCredential(googleCredential);
          } catch (e) {
            if (e is FirebaseAuthException &&
                e.code == 'provider-already-linked') {
              // The user account is already linked to the Google provider, so we can ignore this error
            } else {
              // An unexpected error occurred
              rethrow;
            }
          }
        }
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(googleUser.uid)
            .get();

        if (!doc.exists) {
          initialize_user();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SetupPage()),
          );
        }

        await SessionManager.saveLoginState(true);
        Navigator.pushReplacementNamed(context, '/settings');
      }
    } catch (e) {
      // Handle sign-in errors
      print('Google sign-in error: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Google Sign-in Failed'),
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
            content: const Text('Invalid email or password. Try Signing up'),
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

  Future<void> signUp() async {
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
          MaterialPageRoute(builder: (context) => const SignUpPage()),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Mentor/Authentication')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  'asset/Time_clock_logo.png', width: 80.0, // Adjust as needed
                  height: 80.0,
                ),
              ),
              const Text(
                'Sign in your account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 60,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Email", style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Enter your email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
              ),
              const SizedBox(height: 40.0),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Password", style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Enter your password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                ),
              ),
              const SizedBox(height: 24.0),
              TextButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 40.0),
                ),
                onPressed: _signIn,
                child: const Text("Sign In",
                    style: TextStyle(
                        fontSize: 22.64, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              const Center(
                  child: Text("Don't have an account?",
                      style: TextStyle(fontSize: 20))),
              const SizedBox(height: 10),
              FilledButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 30.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text("Sign Up", style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(height: 24),
              SignInButton(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                Buttons.Google,
                text: "Continue with Google",
                onPressed: signInWithGoogle,
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
