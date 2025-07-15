import 'package:flutter/material.dart';

class AssignTeacherController {
  final BuildContext context;

  String? Teacher;
  String? Class;
  bool isSubmitting = false;

  AssignTeacherController({required this.context});

  String? get audience => Class;
  set audience(String? value) {
    Class = value;
  }

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Assigned $Teacher to $Class successfully!")),
      );

      // Reset form
      Teacher = null;
      Class = null;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to assign teacher: $e")));
    } finally {
      isSubmitting = false;
      onStateChanged();
    }
  }
}
