// ignore_for_file: use_build_context_synchronously

import 'package:demo_vps/View/register_screen/teacher_admission_registration/teacher_admission.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../View/admin/admin_dashboard_screen/dashboard_screen.dart';
import '../View/register_screen/student_registration/student_registration_flow.dart';
import '../View/register_screen/registration_modal_widget.dart';
import '../View/student/student_dashboard/main/student_dashboard.dart';
import '../View/teacher/teacher_dashboard.dart';
import 'dashboard_controller.dart';

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
    const adminEmail = 'admin@gmail.com';
    const adminPassword = 'admin123';
    final enteredEmail = emailController.text.trim();
    final enteredPassword = passwordController.text.trim();

    // Check if it's admin login
    if (enteredEmail == adminEmail && enteredPassword == adminPassword) {
      // Admin login - go directly to dashboard

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
      emailController.clear();
      passwordController.clear();
      return;
    }

    // Non-admin login - verify with Firebase
    try {
      // First, authenticate with Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );

      final hasTeacherRecord = await _teacherRecordExistsByEmail(enteredEmail);
      if (hasTeacherRecord) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TeacherDashboard()),
        );
        emailController.clear();
        passwordController.clear();
        return;
      }

      // After successful authentication, check if this email has a student record
      final hasStudentRecord = await _studentRecordExistsByEmail(enteredEmail);

      if (hasStudentRecord) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChangeNotifierProvider(
                  create: (_) => DashboardController(),
                  child: const StudentDashboard(),
                ),
          ),
        );
      } else {
        _showRegistrationChoice(enteredEmail, enteredPassword);
      }

      emailController.clear();
      passwordController.clear();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'An error occurred')));
    }
  }

  Future<bool> _studentRecordExistsByEmail(String email) async {
    final firestore = FirebaseFirestore.instance;

    // Check Students collection by email
    final studentsQuery =
        await firestore
            .collection('Students')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (studentsQuery.docs.isNotEmpty) {
      return true;
    }

    // Check student applications collection (named with a space in this project)
    final applicationsQuery =
        await firestore
            .collection('student applications')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (applicationsQuery.docs.isNotEmpty) {
      return true;
    }

    return false;
  }

  Future<bool> _teacherRecordExistsByEmail(String email) async {
    final firestore = FirebaseFirestore.instance;

    final teachersQuery =
        await firestore
            .collection('Teachers')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (teachersQuery.docs.isNotEmpty) {
      return true;
    }

    return false;
  }

  void _showRegistrationChoice(String email, String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Complete Registration'),
            content: const Text(
              'No profile found. Please complete Student or Teacher registration.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => StudentRegistrationForm(
                            initialEmail: email,
                            initialPassword: password,
                          ),
                    ),
                  );
                },
                child: const Text('Student Registration'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TeacherAdmission(
                            initialEmail: email,
                            initialPassword: password,
                          ),
                    ),
                  );
                },
                child: const Text('Teacher Registration'),
              ),
            ],
          ),
    );
  }

  void navigateToRegister() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      // ignore: deprecated_member_use
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Builder(
            builder:
                (context) => RegistrationModalWidget(
                  onNext: (email, password) {
                    Navigator.of(context).pop();
                    // After validation, show registration type selection
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) => AlertDialog(
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
                                        builder:
                                            (context) =>
                                                StudentRegistrationForm(
                                                  initialEmail: email,
                                                  initialPassword: password,
                                                ),
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
                                        builder:
                                            (context) => TeacherAdmission(
                                              initialEmail: email,
                                              initialPassword: password,
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Text('Teacher Registration'),
                                ),
                              ],
                            ),
                          ),
                    );
                  },
                ),
          ),
        );
      },
    );
  }
}
