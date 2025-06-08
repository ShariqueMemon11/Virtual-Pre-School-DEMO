import 'package:flutter/material.dart';

class InputFieldWidget extends StatelessWidget {
  final String input;

  const InputFieldWidget({required this.input, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8.0,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(55),
      child: TextField(
        decoration: InputDecoration(
          labelText: input,
          labelStyle: TextStyle(color: Color(0xFF8C5FF5)), // Added label color
          fillColor: const Color.fromARGB(202, 245, 245, 245),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(55),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
