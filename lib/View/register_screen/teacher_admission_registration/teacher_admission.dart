import 'teacher_admission_widget.dart';
import 'package:flutter/material.dart';

class TeacherAdmission extends StatelessWidget {
  final String initialEmail;
  final String initialPassword;
  const TeacherAdmission({
    super.key,
    required this.initialEmail,
    required this.initialPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8C5FF5), Color.fromARGB(255, 156, 129, 219)],
          ),
        ),
        child: TeacherAdmissionPage(
          initialEmail: initialEmail,
          initialPassword: initialPassword,
        ),
      ),
    );
  }
}
