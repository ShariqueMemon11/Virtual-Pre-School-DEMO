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

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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

class TeacherAdmissionDetailController {
  final TeacherAdmissionModel application;

  TeacherAdmissionDetailController(this.application);

  /// 💾 Download CV (Web Safe)
  Future<void> downloadFile(BuildContext context) async {
    try {
      if (application.cvBase64.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file data available for download')),
        );
        return;
      }

      final bytes = base64Decode(application.cvBase64);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..download = "${application.name}_CV.pdf"
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Downloading ${application.name}_CV.pdf..."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error downloading file: $e")));
    }
  }

  /// ✅ Accept Application → move to "Teachers"
  Future<void> acceptApplication(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection("Teachers").add({
        ...application.toMap(),
        'approvedAt': FieldValue.serverTimestamp(),
        'status': 'Approved',
      });

      // Delete from pending
      await _deleteFromApplications();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Application approved and moved to Teachers."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error approving application: $e")),
      );
    }
  }

  /// ❌ Reject Application → remove from "teacher_applications"
  Future<void> rejectApplication(BuildContext context) async {
    try {
      await _deleteFromApplications();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Application rejected and removed."),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error rejecting application: $e")),
      );
    }
  }

  Future<void> _deleteFromApplications() async {
    final firestore = FirebaseFirestore.instance;
    final snap =
        await firestore
            .collection("teacher_applications")
            .where("email", isEqualTo: application.email)
            .get();

    for (var doc in snap.docs) {
      await doc.reference.delete();
    }
  }
}
