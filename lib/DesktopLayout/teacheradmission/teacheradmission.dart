import 'package:demo_vps/DesktopLayout/teacheradmission/teacheradmissionwidget.dart';
import 'package:flutter/material.dart';

// Class name should be PascalCase
class TeacherAdmission extends StatelessWidget {
  const TeacherAdmission({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8C5FF5), // Light gray
              Color.fromARGB(255, 156, 129, 219), // Slightly lighter gray
            ],
          ),
        ),
        child: const TeacherAdmissionwidget(),
      ),
    );
  }
}
