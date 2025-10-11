// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Model/student_registration_data.dart';

class StudentRegistrationController {
  final formKey = GlobalKey<FormState>();

  // Form field controllers
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final homePhoneController = TextEditingController();
  final emailController = TextEditingController();
  final motherCellController = TextEditingController();
  final fatherCellController = TextEditingController();

  final motherNameController = TextEditingController();
  final motherIdController = TextEditingController();
  final motherOccupationController = TextEditingController();

  final fatherNameController = TextEditingController();
  final fatherIdController = TextEditingController();
  final fatherOccupationController = TextEditingController();

  final familyControllers = List.generate(2, (_) => TextEditingController());
  final specialEquipmentController = TextEditingController();
  final allergiesController = TextEditingController();
  final behavioralController = TextEditingController();

  // Extra fields
  DateTime? selectedDate;
  bool policyAccepted = false;

  // Uploaded file data (Base64 or download URLs)
  String? motherCnicFile, fatherCnicFile, birthCertificateFile, childPhotoFile;
  String? motherCnicFileName,
      fatherCnicFileName,
      birthCertificateFileName,
      childPhotoFileName;

  final StudentRegistrationData _data = StudentRegistrationData();

  /// Initialize with email + password (from signup)
  void init(String email, String password) {
    emailController.text = email;
    _data.email = email;
    _data.password = password;
  }

  /// Set child date of birth
  void setDate(DateTime date) {
    selectedDate = date;
  }

  /// Submit registration form → Firestore
  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate() || !policyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill required fields and accept policies."),
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user signed in.");
      }

      final uid = user.uid;
      _data.id = uid; // 👈 make sure model knows its Firestore ID

      // 🧩 Fill model with form data
      _data
        ..childName = nameController.text.trim()
        ..age = ageController.text.trim()
        ..dateOfBirth = selectedDate
        ..homePhone = homePhoneController.text.trim()
        ..email = emailController.text.trim()
        ..motherCell = motherCellController.text.trim()
        ..fatherCell = fatherCellController.text.trim()
        ..motherName = motherNameController.text.trim()
        ..motherId = motherIdController.text.trim()
        ..motherOccupation = motherOccupationController.text.trim()
        ..fatherName = fatherNameController.text.trim()
        ..fatherId = fatherIdController.text.trim()
        ..fatherOccupation = fatherOccupationController.text.trim()
        ..specialEquipment = specialEquipmentController.text.trim()
        ..allergies = allergiesController.text.trim()
        ..behavioralIssues = behavioralController.text.trim()
        ..policyAccepted = policyAccepted
        ..motherCnicFile = motherCnicFile
        ..fatherCnicFile = fatherCnicFile
        ..birthCertificateFile = birthCertificateFile
        ..childPhotoFile = childPhotoFile
        ..otherFamilyMembers =
            familyControllers.map((c) => c.text.trim()).toList();

      // 🔥 Save to Firestore using UID as the document ID
      await FirebaseFirestore.instance
          .collection("student applications")
          .doc(uid)
          .set(_data.toMap(), SetOptions(merge: true));

      // ✅ Show confirmation dialog
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Success"),
              content: const Text(
                "Student registration submitted successfully.\nWaiting for admin approval.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // navigate back
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } catch (e) {
      // ❌ Handle submission errors
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

  /// Dispose controllers properly
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    homePhoneController.dispose();
    emailController.dispose();
    motherCellController.dispose();
    fatherCellController.dispose();
    motherNameController.dispose();
    motherIdController.dispose();
    motherOccupationController.dispose();
    fatherNameController.dispose();
    fatherIdController.dispose();
    fatherOccupationController.dispose();
    for (var c in familyControllers) {
      c.dispose();
    }
    specialEquipmentController.dispose();
    allergiesController.dispose();
    behavioralController.dispose();
  }
}
