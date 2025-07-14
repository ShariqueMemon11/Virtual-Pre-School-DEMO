import 'package:demo_vps/Model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../View/DesktopLayout/Dashboardscreen/dashboardscreen.dart';
import '../../View/DesktopLayout/registersteps/student_registration_flow.dart';
import '../../View/DesktopLayout/teacheradmission/teacheradmission.dart';

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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Registration Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentRegistrationFlow(),
                  ),
                );
              },
              child: const Text('Student Registration'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeacherAdmission(),
                  ),
                );
              },
              child: const Text('Teacher Registration'),
            ),
          ],
        ),
      ),
    );
  }
}
