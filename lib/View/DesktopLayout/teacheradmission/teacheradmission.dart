import 'package:flutter/material.dart';
import 'package:demo_vps/View/DesktopLayout/teacheradmission/teacheradmissionwidget.dart';

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
            colors: [Color(0xFF8C5FF5), Color.fromARGB(255, 156, 129, 219)],
          ),
        ),
        child: const TeacherAdmissionWidget(),
      ),
    );
  }
}
