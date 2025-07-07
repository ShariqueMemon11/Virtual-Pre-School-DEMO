import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/inputfieldwidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/primarybuttonwidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/secondarybuttonwidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Class name should be PascalCase
class Registerwidget extends StatefulWidget {
  const Registerwidget({super.key});

  @override
  State<Registerwidget> createState() => _RegisterwidgetState();
}

class _RegisterwidgetState extends State<Registerwidget> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> createuserwithemailpassword() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      await FirebaseFirestore.instance
          .collection('students')
          .doc(userCredential.user!.uid)
          .set({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
            'email': _emailController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });
      _nameController.clear();
      _phoneController.clear();
      _addressController.clear();
      _emailController.clear();
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
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
              offset: Offset(0, 3),
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
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30.h),
              InputFieldWidget(input: "Name", controller: _nameController),
              SizedBox(height: 30.h),
              InputFieldWidget(input: "Phone", controller: _phoneController),
              SizedBox(height: 30.h),
              InputFieldWidget(input: "Address", controller: _addressController),
              SizedBox(height: 30.h),
              InputFieldWidget(input: "Email", controller: _emailController),
              SizedBox(height: 30.h),
              InputFieldWidget(input: "Password", controller: _passwordController, obscureText: true),
              SizedBox(height: 30.h),
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
      ),
    );
  }
}
