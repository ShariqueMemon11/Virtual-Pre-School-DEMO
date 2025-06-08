import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/inputfieldwidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/primarybuttonwidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/secondarybuttonwidget.dart';

// Class name should be PascalCase
class Registerwidget extends StatefulWidget {
  const Registerwidget({super.key});

  @override
  State<Registerwidget> createState() => _RegisterwidgetState();
}

class _RegisterwidgetState extends State<Registerwidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> createuserwithemailpassword() async {
    // ignore: unused_local_variable
    final UserCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
    _emailController.clear();
    _passwordController.clear();
  }

  void back(BuildContext context) {
    Navigator.pop(context);
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
              "Register",
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

            SizedBox(height: 70.h),
            Row(
              spacing: 10.w,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Primarybuttonwidget(
                  run: () => createuserwithemailpassword(),
                  input: "Register",
                ),
                Secondarybuttonwidget(run: () => back(context), input: "Login"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
