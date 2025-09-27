import 'package:demo_vps/View/DesktopLayout/teacherAdmissionRegistration/teacheradmissionwidget.dart';
import 'package:flutter/material.dart';

class TeacherAdmission extends StatelessWidget {
  final String initialUsername;
  final String initialEmail;
  final String initialPassword;
  const TeacherAdmission({
    super.key,
    required this.initialUsername,
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
        child: TeacherAdmissionWidget(
          initialUsername: initialUsername,
          initialEmail: initialEmail,
          initialPassword: initialPassword,
        ),
      ),
    );
  }
}
