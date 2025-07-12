import 'package:demo_vps/Model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../View/DesktopLayout/Dashboardscreen/dashboardscreen.dart';
import '../../View/DesktopLayout/registerscreen.dart/registerscreen.dart';

class LoginController {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final BuildContext context;

  LoginController({
    required this.emailController,
    required this.passwordController,
    required this.context,
  });

  Future<void> loginUserWithEmailPassword() async {
    final dummyUser = UserModel(
      name: 'Alice Smith',
      phone: '+1 234 567 8900',
      address: '123 Main Street, Springfield',
      email: 'alice@example.com',
    );

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      final user = userCredential.user;
      if (user != null) {
        final doc =
            await FirebaseFirestore.instance
                .collection('students')
                .doc(user.uid)
                .get();
        if (doc.exists) {
          final data = doc.data();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(user: dummyUser),
            ),
          );
        }
      }
      emailController.clear();
      passwordController.clear();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'An error occurred')));
    }
  }

  void navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }
}
