import 'package:flutter/material.dart';

class Primarybuttonwidget extends StatelessWidget {
  final String input;
  final VoidCallback run;

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
        backgroundColor: Color(0xFF8C5FF5),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 8,
        shadowColor: Color(0xFF8C5FF5),
      ),
      child: Text(input),
    );
  }
}
