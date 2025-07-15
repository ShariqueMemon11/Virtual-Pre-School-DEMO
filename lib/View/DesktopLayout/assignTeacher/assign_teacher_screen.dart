import 'package:flutter/material.dart';
import 'assign_teacher_widget.dart';

class AssignTeacherScreen extends StatelessWidget {
  const AssignTeacherScreen({super.key});

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
        child: const Center(child: AssignTeacherWidget()),
      ),
    );
  }
}
