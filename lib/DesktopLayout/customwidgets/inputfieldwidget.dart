import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputFieldWidget extends StatelessWidget {
  final String input;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;

  const InputFieldWidget({
    required this.input,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8.0,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(55.r),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: input,
          hintStyle: TextStyle(color: Color(0xFF8C5FF5)),
          fillColor: const Color.fromARGB(202, 245, 245, 245),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(55.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}