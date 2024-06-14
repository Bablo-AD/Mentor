import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:convert';

import '../setup/setup_roller.dart';
import 'loader.dart';
import 'data.dart';

class Firebaseauthhelper {
  final BuildContext context;
  Firebaseauthhelper({required this.context});
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent check your email'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Error occurred check your email or create new account'),
          ),
        );
      }
    }
  }

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
      //Handle sign-in errors
      print('Google sign-in error: $e');
      if (context.mounted) {
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

  Future<void> signIn(emailController, passwordController) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.trim(),
        password: passwordController.trim(),
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

  Future<void> signUp(emailController, passwordController) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.trim(),
        password: passwordController.trim(),
      );
      // User account creation successful
      User? user = userCredential.user;
      if (user != null) {
        Data.userId = user.uid;
        initialize_user();
        await SessionManager.saveLoginState(true);

        Navigator.pushReplacementNamed(context, '/signup');
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
}
