import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/material.dart';

import '../utils/auth.dart';
import '../utils/widgets/common.dart';

// class EmailAuth extends StatefulWidget {
//   static const id = 'EmailAuth';
//   const EmailAuth({super.key});

//   @override
//   _EmailAuthState createState() => _EmailAuthState();
// }

// class _EmailAuthState extends State<EmailAuth> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final firebaseauthhelper _auth = firebaseauthhelper(context: context);
//     return Scaffold(
//       appBar: AppBar(title: const Text('Mentor/Authentication')),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text('Sign up',
//                   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 40),
//               buildTextField(_emailController, "Email"),
//               buildTextField(_passwordController, "Password",
//                   obscureText: true),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 20.0, horizontal: 40.0),
//                 ),
//                 onPressed: () async {
//                   await _auth.signIn(_emailController, _passwordController);
//                 },
//                 child: const Text("Sign In",
//                     style:
//                         TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               ),
//               const SizedBox(height: 24),
//               const Text("Don't have an account?",
//                   style: TextStyle(fontSize: 20)),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 10.0, horizontal: 30.0),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/signup');
//                 },
//                 child: const Text("Sign Up", style: TextStyle(fontSize: 22)),
//               ),
//               const SizedBox(height: 24),
//               const Text("Or continue with", style: TextStyle(fontSize: 20)),
//               SignInButton(
//                 Buttons.Google,
//                 text: "Continue with Google",
//                 onPressed: _auth.signInWithGoogle,
//                 elevation: 1,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0)),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow.shade100, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
      child: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                const SizedBox(height: 30.0),
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
                const SizedBox(height: 20.0),
                CustomTextFormField(
                  hintText: 'E-mail',
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                CustomTextFormField(
                  hintText: 'Password',
                  controller: _passwordController,
                  prefixIcon: Icons.lock,
                  obscureText: !_passwordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                CustomTextFormField(
                  hintText: 'Retype Password',
                  prefixIcon: Icons.phone,
                  obscureText: !_passwordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      auth.signUp(
                          _emailController.text, _passwordController.text);
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80.0, vertical: 15.0),
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
                const Text(
                  'Or create with',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 20.0),
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
    ));
  }
}
