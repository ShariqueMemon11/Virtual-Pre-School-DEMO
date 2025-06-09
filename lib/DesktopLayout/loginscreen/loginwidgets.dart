import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/DesktopLayout/registerscreen.dart/registerscreen.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/primarybuttonwidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/secondarybuttonwidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/inputfieldwidget.dart';

// Class name should be PascalCase
class LoginWidgets extends StatefulWidget {
  const LoginWidgets({super.key});

  @override
  State<LoginWidgets> createState() => _LoginWidgetsState();
}

class _LoginWidgetsState extends State<LoginWidgets> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> loginuserwithemailpassword() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      print(userCredential.user?.email);
      print("Login successful");
      _emailController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }

    // Implement your login logic here
  }

  void login(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Scaffold()),
    );
  }

  void register(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    return Center(
      child: Container(
        padding: EdgeInsets.all(14.0.h),
        height: screenHeight * 0.6,
        width: screenWidth * 0.25,
        decoration: BoxDecoration(
          color: const Color.fromARGB(141, 233, 233, 233),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 7,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Login",
              style: TextStyle(
                fontSize: 50.sp,
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 50.h),
            InputFieldWidget(input: "Email", controller: _emailController),
            SizedBox(height: 30.h),
            InputFieldWidget(
              input: "Password",
              controller: _passwordController,
            ),
            SizedBox(height: 20.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Forgot Password",
                  style: TextStyle(color: Color(0xFF8C5FF5)),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              spacing: 10.w,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Primarybuttonwidget(
                  run: () => loginuserwithemailpassword(),
                  input: "Login",
                ),
                Secondarybuttonwidget(
                  run: () => register(context),
                  input: "Register",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
