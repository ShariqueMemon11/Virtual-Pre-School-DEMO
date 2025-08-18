import 'package:demo_vps/Model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../View/DesktopLayout/adminDashboardScreen/dashboardscreen.dart';
import '../../View/DesktopLayout/studentRegisterManagement/studentRegistration/student_registration_flow.dart';
import '../../View/DesktopLayout/teacherRegisterManagement/teacherAdmissionRegistration/teacheradmission.dart';
import '../../View/DesktopLayout/customwidgets/registration_modal_widget.dart';
import '../../View/DesktopLayout/adminDashboardScreen/demo_screen.dart';

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
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: enteredEmail,
            password: enteredPassword,
          );

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
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Builder(
            builder:
                (context) => RegistrationModalWidget(
                  onNext: (username, email, password) {
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
                                                StudentRegistrationFlow(
                                                  initialUsername: username,
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
                                              initialUsername: username,
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
