import 'package:flutter/material.dart';

class AssignTeacherController {
  final BuildContext context;

  // ignore: non_constant_identifier_names
  String? Teacher;
  // ignore: non_constant_identifier_names
  String? Class;
  bool isSubmitting = false;

  AssignTeacherController({required this.context});

  String? get audience => Class;
  set audience(String? value) {
    Class = value;
  }

  // ignore: non_constant_identifier_names
  void AssignTeacher(VoidCallback onStateChanged) async {
    if (Teacher == null || Class == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both teacher and class")),
      );
      return;
    }

    isSubmitting = true;
    onStateChanged();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Assigned $Teacher to $Class successfully!")),
      );

      // Reset form
      Teacher = null;
      Class = null;
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to assign teacher: $e")));
    } finally {
      isSubmitting = false;
      onStateChanged();
    }
  }
}
