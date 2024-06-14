import 'package:flutter/material.dart';

import '../utils/widgets/common.dart';
import '/utils/auth.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = Firebaseauthhelper(context: context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mentor/Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Sign in to continue",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              CustomTextFormField(
                hintText: "Email",
                prefixIcon: Icons.email,
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              CustomTextFormField(
                hintText: "Password",
                prefixIcon: Icons.lock,
                controller: _passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: () {
                  if (_emailController.text.isNotEmpty) {
                    auth.resetPassword(_emailController.text);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your email'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Forgot Password?',
                ),
              ),
              const SizedBox(height: 30.0),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    auth.signIn(
                        _emailController.text, _passwordController.text);
                  }
                },
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
