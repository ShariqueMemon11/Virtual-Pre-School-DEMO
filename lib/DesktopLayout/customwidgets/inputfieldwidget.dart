import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputFieldWidget extends StatelessWidget {
  final String input;

  const InputFieldWidget({required this.input, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8.0,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(55.r),
      child: TextField(
        decoration: InputDecoration(
          labelStyle: TextStyle(color: Color(0xFF8C5FF5)), // Added label color
          fillColor: const Color.fromARGB(202, 245, 245, 245),
          filled: true,
          hintText: input,
          hintStyle: TextStyle(color: Color(0xFF8C5FF5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(55.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
