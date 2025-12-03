// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../../controllers/student_assign_controller.dart';
import '../../../Model/student_data.dart';
import '../../../Model/class_model.dart';

class AssignClassDialog extends StatefulWidget {
  final StudentData student;
  final StudentController controller;

  const AssignClassDialog({
    super.key,
    required this.student,
    required this.controller,
  });

  @override
  State<AssignClassDialog> createState() => _AssignClassDialogState();
}

class _AssignClassDialogState extends State<AssignClassDialog> {
  String? selectedClass;
  List<ClassModel> classes = [];

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  Future<void> loadClasses() async {
    classes = await widget.controller.getClasses();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Assign Class to ${widget.student.childName}"),
      content:
          classes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField(
                value: selectedClass,
                items:
                    classes.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.gradeName),
                      );
                    }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedClass = val;
                  });
                },
                decoration: const InputDecoration(labelText: "Select Class"),
              ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed:
              selectedClass == null
                  ? null
                  : () async {
                    await widget.controller.assignClass(
                      studentId: widget.student.id!,
                      oldClassId: widget.student.assignedClass,
                      newClassId: selectedClass!,
                    );

                    Navigator.pop(context);
                  },
          child: const Text("Assign"),
        ),
      ],
    );
  }
}
