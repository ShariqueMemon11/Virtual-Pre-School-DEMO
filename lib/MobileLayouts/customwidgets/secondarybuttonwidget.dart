import 'package:flutter/material.dart';

class Secondarybuttonwidget extends StatelessWidget {
  final String input;
  final VoidCallback run;

  const Secondarybuttonwidget({
    required this.run,
    required this.input,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: run,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF8C5FF5),
        elevation: 8,
        shadowColor: Color(0xFF8C5FF5),
      ),
      child: Text(input),
    );
  }
}
