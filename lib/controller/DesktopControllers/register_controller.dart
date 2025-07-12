import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterController {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final BuildContext context;

  RegisterController({
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.emailController,
    required this.passwordController,
    required this.context,
  });

  Future<void> registerUser() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('students')
          .doc(userCredential.user!.uid)
          .set({
            'name': nameController.text.trim(),
            'phone': phoneController.text.trim(),
            'address': addressController.text.trim(),
            'email': emailController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      nameController.clear();
      phoneController.clear();
      addressController.clear();
      emailController.clear();
      passwordController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void navigateBackToLogin() {
    Navigator.pop(context);
  }
}
