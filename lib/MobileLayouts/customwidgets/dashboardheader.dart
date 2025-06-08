import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String input;

  const DashboardHeader({required this.input, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(color: const Color(0xFF8C5FF5)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: Text(
            "Hello, $input",
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
