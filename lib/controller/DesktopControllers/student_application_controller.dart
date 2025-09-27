import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Model/student_registration_data.dart';

class StudentRegistrationController {
  final formKey = GlobalKey<FormState>();

  // controllers
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

  // extra fields
  DateTime? selectedDate;
  bool policyAccepted = false;

  // files
  String? motherCnicFile, fatherCnicFile, birthCertificateFile;
  String? motherCnicFileName, fatherCnicFileName, birthCertificateFileName;

  // initial values
  void init(String email, String password) {
    emailController.text = email;
    _data.email = email;
    _data.password = password;
  }

  final StudentRegistrationData _data = StudentRegistrationData();

  void setDate(DateTime date) {
    selectedDate = date;
  }

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate() || !policyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill required fields and accept policies."),
        ),
      );
      return;
    }

    // map values to model
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
      ..otherFamilyMembers =
          familyControllers.map((c) => c.text.trim()).toList();

    try {
      await FirebaseFirestore.instance
          .collection("students")
          .add(_data.toMap());

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Success"),
              content: const Text(
                "Student registration submitted successfully.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
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
