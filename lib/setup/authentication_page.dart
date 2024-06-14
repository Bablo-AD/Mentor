import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import '../utils/auth.dart';
import '../utils/widgets/common.dart';

class EmailAuth extends StatefulWidget {
  const EmailAuth({Key? key}) : super(key: key);

  @override
  _EmailAuthState createState() => _EmailAuthState();
}

class _EmailAuthState extends State<EmailAuth> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    final Firebaseauthhelper auth = Firebaseauthhelper(context: context);
    return Scaffold(
        // backgroundColor: const Color.fromRGBO(255, 237, 212, 1),
        body: SingleChildScrollView(
            child: Column(children: [
      ClipPath(
        clipper: WaveClipperTwo(flip: true),
        child: Container(
          height: 120,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x73EECE13), Color.fromARGB(136, 255, 250, 94)],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40.0),
                CustomTextFormField(
                  hintText: 'Your Name',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30.0),
                CustomTextFormField(
                  hintText: 'Your E-mail',
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30.0),
                CustomTextFormField(
                  hintText: 'Password',
                  controller: _passwordController,
                  prefixIcon: Icons.lock,
                  obscureText: !_passwordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30.0),
                CustomTextFormField(
                  hintText: 'Retype Password',
                  prefixIcon: Icons.check,
                  obscureText: !_passwordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40.0),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      auth.signUp(
                          _emailController.text, _passwordController.text);
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60.0, vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // text: TextSpan(
                  //   style: const TextStyle(fontSize: 16.0, color: Colors.black),
                  children: [
                    const Text('Already a user? '),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the sign in page
                        Navigator.pushNamed(context, '/signin');
                      },
                      child: const Text(
                        'Sign in',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                const Text(
                  'Or create with',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 10.0),
                SignInButton(
                  Buttons.Google,
                  text: ' Google SignIn',
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  onPressed: auth.signInWithGoogle,
                )
              ],
            ),
          ),
        ),
      ),
    ])));
  }
}
