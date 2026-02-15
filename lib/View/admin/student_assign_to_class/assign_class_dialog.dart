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
  String? selectedCategory;
  String? selectedClass;

  List<ClassModel> classes = [];

  final List<String> categories = ["Playgroup", "Nursery", "Kindergarten"];

  Future<void> loadClassesByCategory(String category) async {
    final result = await widget.controller.getClassesByCategory(category);

    setState(() {
      classes = result;
      selectedClass = null; // reset class selection
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Assign Class to ${widget.student.childName}"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🔥 CATEGORY DROPDOWN
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: "Select Category",
                prefixIcon: Icon(Icons.category),
              ),
              items:
                  categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
              onChanged: (val) {
                setState(() {
                  selectedCategory = val;
                });

                if (val != null) {
                  loadClassesByCategory(val);
                }
              },
            ),

            const SizedBox(height: 16),

            /// 🔥 CLASS DROPDOWN
            if (selectedCategory != null)
              DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: const InputDecoration(
                  labelText: "Select Class",
                  prefixIcon: Icon(Icons.class_),
                ),
                items:
                    classes
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.gradeName),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedClass = val;
                  });
                },
              ),

            if (selectedCategory != null && classes.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text("No classes available in this category"),
              ),
          ],
        ),
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
                    try {
                      await widget.controller.assignClass(
                        studentId: widget.student.id!,
                        oldClassId: widget.student.assignedClass,
                        newClassId: selectedClass!,
                      );

                      if (!context.mounted) return;
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  },
          child: const Text("Assign"),
        ),
      ],
    );
  }
}
