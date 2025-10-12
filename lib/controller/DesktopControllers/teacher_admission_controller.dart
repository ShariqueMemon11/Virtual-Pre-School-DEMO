// lib/controller/DesktopControllers/teacher_admission_controller.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Model/teacher_admission_model.dart';

class TeacherAdmissionController {
  // ---------------- Form and State ---------------- //
  final formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final qualificationController = TextEditingController();
  final experienceController = TextEditingController();
  final subjectsController = TextEditingController();
  final addressController = TextEditingController();

  // File Data
  String? cvFileName;
  String? cvBase64;

  // Auth Info
  // ignore: unused_field
  late String _email;
  // ignore: unused_field
  late String _password;

  // ---------------- Initialization ---------------- //
  void init(String email, String password) {
    _email = email;
    _password = password;
    emailController.text = email;
  }

  // ---------------- Validators ---------------- //
  String? requiredValidator(String? value) =>
      value == null || value.trim().isEmpty ? "Required" : null;

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return "Required";
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
      return "Enter a valid email";
    }
    return null;
  }

  // ---------------- File Picker ---------------- //
  Future<void> pickCV(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true, // works for web and desktop
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.single;
        cvFileName = pickedFile.name;

        if (kIsWeb) {
          cvBase64 = base64Encode(pickedFile.bytes!);
        } else {
          final file = File(pickedFile.path!);
          final bytes = await file.readAsBytes();
          cvBase64 = base64Encode(bytes);
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('CV selected: $cvFileName')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No file selected')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  // ---------------- Submit to Firestore ---------------- //
  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    if (cvBase64 == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please upload your CV.")));
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting application...')),
      );

      // Get current logged-in user UID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");
      final uid = user.uid;

      // Build model
      final model = TeacherAdmissionModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        qualification: qualificationController.text.trim(),
        experience: experienceController.text.trim(),
        subjects: subjectsController.text.trim(),
        address: addressController.text.trim(),
        cvBase64: cvBase64!,
        createdAt: Timestamp.now(),
      );

      // Save to Firestore (doc ID = UID)
      await FirebaseFirestore.instance
          .collection('teacher_applications')
          .doc(uid)
          .set(model.toMap(), SetOptions(merge: true));

      // Success dialog
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Success"),
              content: const Text(
                "Teacher application submitted successfully. Waiting for admin approval.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );

      _clearForm();
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Error"),
              content: Text("Failed to submit: $e"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  // ---------------- Clear Form ---------------- //
  void _clearForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    qualificationController.clear();
    experienceController.clear();
    subjectsController.clear();
    addressController.clear();
    cvFileName = null;
    cvBase64 = null;
  }

  // ---------------- Dispose ---------------- //
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    qualificationController.dispose();
    experienceController.dispose();
    subjectsController.dispose();
    addressController.dispose();
  }
}
