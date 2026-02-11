// student_list_view.dart
import 'package:flutter/material.dart';
import '../../../Model/student_data.dart';
import '../../../controllers/student_assign_controller.dart';
import './assign_class_dialog.dart';

class StudentListView extends StatelessWidget {
  final List<StudentData> students;
  final StudentController controller;
  final bool shrinkWrap; // NEW: allows nested lists

  const StudentListView({
    super.key,
    required this.students,
    required this.controller,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return const Center(child: Text("No students found"));
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.all(0),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];

        return Card(
          child: ListTile(
            title: Text(student.childName ?? "Unknown"),
            subtitle:
                student.assignedClass == null
                    ? const Text("Class: Not Assigned")
                    : FutureBuilder(
                      future: controller.getClassName(student.assignedClass!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text("Class: Loading...");
                        }
                        if (!snapshot.hasData) {
                          return const Text("Class: Unknown");
                        }
                        return Text("Class: ${snapshot.data}");
                      },
                    ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => AssignClassDialog(
                        student: student,
                        controller: controller,
                      ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
