import '../core/loader.dart';
import '../core/data.dart';
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
              throw e;
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
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Making Earth a Productive Place',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  TextField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  OutlinedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 40.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text("Sign In"),
                  ),
                  const SizedBox(height: 24),
                  const Center(child: Text("New to the jungle?")),
                  const SizedBox(height: 8),
                  FilledButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 40.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpPage()),
                      );
                    },
                    child: const Text("Sign Up"),
                  ),
                  const SizedBox(height: 24),
                  SignInButton(
                    Buttons.Google,
                    text: "Sign up with Google",
                    onPressed: signInWithGoogle,
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
