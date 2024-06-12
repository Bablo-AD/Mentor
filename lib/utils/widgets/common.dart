import 'package:flutter/material.dart';

Widget buildTextField(TextEditingController controller, String label,
    {bool obscureText = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 10),
      TextField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          labelText: "Enter your $label",
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
      ),
      const SizedBox(height: 40.0),
    ],
  );
}

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextEditingController? controller;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.validator,
    this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
