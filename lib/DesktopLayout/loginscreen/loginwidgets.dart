import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/DesktopLayout/registerscreen.dart/registerscreen.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/primarybuttonwidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/secondarybuttonwidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/inputfieldwidget.dart';
import 'package:demo_vps/DesktopLayout/dashboardscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Class name should be PascalCase
class LoginWidgets extends StatefulWidget {
  const LoginWidgets({super.key});

  @override
  State<LoginWidgets> createState() => _LoginWidgetsState();
}

class _LoginWidgetsState extends State<LoginWidgets> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> loginuserwithemailpassword() async {
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }

    // Implement your login logic here
  }

  Future<void> createuserwithemailpassword() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
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

      // Save extra info to Firestore
      await FirebaseFirestore.instance
          .collection('students')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        // Add other fields as needed
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Optionally clear controllers or navigate
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _addressController.clear();
      // ...etc

      // Show success message or navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    }
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
            SizedBox(height: 30.h),
            InputFieldWidget(input: "Name", controller: _nameController),
            SizedBox(height: 30.h),
            InputFieldWidget(input: "Phone", controller: _phoneController),
            SizedBox(height: 30.h),
            InputFieldWidget(input: "Address", controller: _addressController),
            SizedBox(height: 30.h),
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
                  run: () => createuserwithemailpassword(),
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
