import 'package:demo_vps/Model/user_model.dart';
import 'package:demo_vps/View/DesktopLayout/registerScreen/teacherAdmissionRegistration/teacheradmission.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../View/DesktopLayout/admin/adminDashboardScreen/dashboardscreen.dart';
import '../../View/DesktopLayout/registerScreen/studentRegistration/student_registration_flow.dart';
import '../../View/DesktopLayout/registerScreen/registration_modal_widget.dart';
import '../../View/DesktopLayout/student/studentDashboard/student_dashboard.dart';
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
      final dummyUser = UserModel(
        name: 'Admin',
        phone: '0316221145',
        address: 'Lahore',
        email: enteredEmail,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(user: dummyUser),
        ),
      );
      emailController.clear();
      passwordController.clear();
      return;
    }

    // Non-admin login - verify with Firebase
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: enteredEmail,
        password: enteredPassword,
      );

      // After sign-in, check if this email already has a student record
      final hasStudentRecord = await _studentRecordExistsByEmail(enteredEmail);

      if (hasStudentRecord) {
        // Student profile exists -> go to dashboard with provider
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
        // No profile yet -> go to registration flow with prefilled creds
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => StudentRegistrationForm(
                  initialEmail: enteredEmail,
                  initialPassword: enteredPassword,
                ),
          ),
        );
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
    if (studentsQuery.docs.isNotEmpty) return true;

    // Check student applications collection (named with a space in this project)
    final applicationsQuery =
        await firestore
            .collection('student applications')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    return applicationsQuery.docs.isNotEmpty;
  }

  void navigateToRegister() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
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
