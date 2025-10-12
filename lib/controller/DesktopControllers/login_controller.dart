import 'package:demo_vps/Model/user_model.dart';
import 'package:demo_vps/View/DesktopLayout/registerScreen/teacherAdmissionRegistration/teacheradmission.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../View/DesktopLayout/admin/adminDashboardScreen/dashboardscreen.dart';
import '../../View/DesktopLayout/registerScreen/studentRegistration/student_registration_flow.dart';
import '../../View/DesktopLayout/registerScreen/registration_modal_widget.dart';
import '../../View/DesktopLayout/admin/adminDashboardScreen/demo_screen.dart';

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
      // Student/teacher login successful - go to demo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DemoScreen()),
      );

      emailController.clear();
      passwordController.clear();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'An error occurred')));
    }
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
