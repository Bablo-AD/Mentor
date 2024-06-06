import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/material.dart';

import '../utils/auth.dart';

class EmailAuth extends StatefulWidget {
  static const id = 'EmailAuth';
  const EmailAuth({super.key});

  @override
  _EmailAuthState createState() => _EmailAuthState();
}

class _EmailAuthState extends State<EmailAuth> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final firebaseauthhelper _auth = firebaseauthhelper(context: context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mentor/Authentication')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign in your account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 40,
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
                onPressed: () async {
                  await _auth.signIn(_emailController, _passwordController);
                },
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
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text("Sign Up", style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(height: 24),
              SignInButton(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                Buttons.Google,
                text: "Continue with Google",
                onPressed: _auth.signInWithGoogle,
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
