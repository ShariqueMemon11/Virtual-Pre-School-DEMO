import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class TeacherAdmissionController {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController qualificationController;
  final TextEditingController experienceController;
  final TextEditingController subjectsController;
  final TextEditingController addressController;
  final BuildContext context;
  final GlobalKey<FormState> formKey;

  File? _cvFile;
  String? cvFileName;

  TeacherAdmissionController({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.qualificationController,
    required this.experienceController,
    required this.subjectsController,
    required this.addressController,
    required this.context,
    required this.formKey,
  });

  String? requiredValidator(String? value) =>
      value == null || value.isEmpty ? "Required" : null;

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) return "Required";
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  void pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      _cvFile = File(result.files.single.path!);
      cvFileName = result.files.single.name;
    }
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;
    if (_cvFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please upload your CV!')));
      return;
    }

    // Handle the actual submission logic (e.g., Firebase storage, Firestore)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form submitted successfully!')),
    );
  }

  void navigateBack() {
    Navigator.pop(context);
  }
}
