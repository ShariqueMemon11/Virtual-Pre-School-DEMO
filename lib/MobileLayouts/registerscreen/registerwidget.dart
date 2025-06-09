import 'package:demo_vps/MobileLayouts/customwidgets/primarybuttonwidget.dart';
import 'package:demo_vps/MobileLayouts/customwidgets/secondarybuttonwidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:demo_vps/MobileLayouts/customwidgets/inputfieldwidget.dart';

// Class name should be PascalCase
class Registerwidget extends StatefulWidget {
  const Registerwidget({super.key});

  @override
  State<Registerwidget> createState() => _RegisterwidgetState();
}

class _RegisterwidgetState extends State<Registerwidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void back(BuildContext context) {
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center vertically
      children: [
        Text(
          "Register",
          style: TextStyle(
            color: Color(0xFF8C5FF5),
            fontSize: 40, // Added font size
            fontWeight: FontWeight.bold, // Added font weight
          ),
        ),
        SizedBox(height: 30),

        InputFieldWidget(input: "Email", controller: _emailController),
        SizedBox(height: 30), // Added spacing
        InputFieldWidget(input: "Password", controller: _passwordController),
        SizedBox(height: 30), // Added spacing
        Row(
          children: [
            Primarybuttonwidget(run: () => {}, input: "Register"),
            SizedBox(width: 10),
            Secondarybuttonwidget(run: () => back(context), input: "Login"),
          ],
        ),
      ],
    );
  }
}
