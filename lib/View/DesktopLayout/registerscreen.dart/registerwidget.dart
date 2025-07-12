import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/controller/DesktopControllers/register_controller.dart';
import 'package:demo_vps/View/DesktopLayout/customwidgets/inputfieldwidget.dart';
import 'package:demo_vps/View/DesktopLayout/customwidgets/primarybuttonwidget.dart';
import 'package:demo_vps/View/DesktopLayout/customwidgets/secondarybuttonwidget.dart';

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late RegisterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RegisterController(
      nameController: _nameController,
      phoneController: _phoneController,
      addressController: _addressController,
      emailController: _emailController,
      passwordController: _passwordController,
      context: context,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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
        height: screenHeight * 0.75,
        width: screenWidth * 0.25,
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Register",
                style: TextStyle(
                  fontSize: 50.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30.h),
              InputFieldWidget(input: "Name", controller: _nameController),
              SizedBox(height: 30.h),
              InputFieldWidget(input: "Phone", controller: _phoneController),
              SizedBox(height: 30.h),
              InputFieldWidget(
                input: "Address",
                controller: _addressController,
              ),
              SizedBox(height: 30.h),
              InputFieldWidget(input: "Email", controller: _emailController),
              SizedBox(height: 30.h),
              InputFieldWidget(
                input: "Password",
                controller: _passwordController,
                obscureText: true,
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Primarybuttonwidget(
                    run: _controller.registerUser,
                    input: "Register",
                  ),
                  Secondarybuttonwidget(
                    run: _controller.navigateBackToLogin,
                    input: "Login",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
