import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/View/DesktopLayout/customwidgets/inputfieldwidget.dart';
import 'package:demo_vps/View/DesktopLayout/customwidgets/primarybuttonwidget.dart';
import 'package:demo_vps/View/DesktopLayout/customwidgets/secondarybuttonwidget.dart';
import 'package:demo_vps/controller/DesktopControllers/login_controller.dart';

class LoginWidgets extends StatefulWidget {
  const LoginWidgets({super.key});

  @override
  State<LoginWidgets> createState() => _LoginWidgetsState();
}

class _LoginWidgetsState extends State<LoginWidgets> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController(
      emailController: _emailController,
      passwordController: _passwordController,
      context: context,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Center(
      child: Container(
        padding: EdgeInsets.all(14.0.h),
        // Remove height constraint for tighter fit
        width: screenWidth * 0.25,
        margin: const EdgeInsets.symmetric(vertical: 32), // Add vertical margin
        decoration: BoxDecoration(
          color: const Color.fromARGB(141, 233, 233, 233),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 7,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Only as tall as needed
          children: [
            Text(
              "Login",
              style: TextStyle(
                fontSize: 50.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 50.h),
            InputFieldWidget(input: "Email", controller: _emailController),
            SizedBox(height: 30.h),
            InputFieldWidget(
              input: "Password",
              controller: _passwordController,
              obscureText: true,
            ),
            SizedBox(height: 20.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Forgot Password",
                  style: TextStyle(
                    color: const Color(0xFF8C5FF5),
                    fontSize: 15.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Primarybuttonwidget(
                  run: _controller.loginUserWithEmailPassword,
                  input: "Login",
                ),
                SizedBox(width: 20.w),
                Secondarybuttonwidget(
                  run: () => _controller.navigateToRegister(),
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
