import 'package:flutter/material.dart';

class Primarybuttonwidget extends StatelessWidget {
  final String input;
  final VoidCallback? run; // <-- made nullable

  const Primarybuttonwidget({
    required this.run,
    required this.input,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: run,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8C5FF5),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 8,
        shadowColor: const Color(0xFF8C5FF5),
      ),
      child: Text(input),
    );
  }
}
