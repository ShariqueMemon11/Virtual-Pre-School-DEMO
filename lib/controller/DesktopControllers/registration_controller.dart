import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationController {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final BuildContext context;

  RegistrationController({
    required this.emailController,
    required this.passwordController,
    required this.context,
  });

  Future<void> registerUser() async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Initial registration - create document with UID
      await FirebaseFirestore.instance
          .collection("student applications")
          .doc(credential.user!.uid)
          .set({
            'email': emailController.text.trim(),
            'uid': credential.user!.uid,
            'approval': "pending",
            'createdAt': FieldValue.serverTimestamp(),

            // Add initial fields
          }, SetOptions(merge: true));
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registered: ${credential.user?.email}")),
      );
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email already registered';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
