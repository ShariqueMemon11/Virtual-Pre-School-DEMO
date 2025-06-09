import 'package:demo_vps/MobileLayouts/customwidgets/inputfieldwidget.dart';
import 'package:flutter/material.dart';
import 'package:demo_vps/MobileLayouts/registerscreen/registerscreen.dart';
import 'package:demo_vps/MobileLayouts/customwidgets/primarybuttonwidget.dart';
import 'package:demo_vps/MobileLayouts/customwidgets/secondarybuttonwidget.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  void register(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center vertically
      children: [
        Text(
          "Login",
          style: TextStyle(
            color: Color(0xFF8C5FF5),
            fontSize: 40, // Added font size
            fontWeight: FontWeight.bold, // Added font weight
          ),
        ),
        SizedBox(height: 30),
        InputFieldWidget(input: "Email", controller: _emailController),
        SizedBox(height: 30), // Added spacing
        InputFieldWidget(
          input: "Password",
          controller: _passwordController,
          obscureText: true,
        ),
        Container(
          margin: EdgeInsets.only(left: 10, top: 20),
          alignment: Alignment.centerLeft,
          child: Text(
            "Forgot Password?",
            style: TextStyle(
              color: Color(0xFF8C5FF5),
              fontSize: 14, // Added font size
              fontWeight: FontWeight.bold, // Added font weight
            ),
          ),
        ),
        SizedBox(height: 30),
        Row(
          children: [
            Primarybuttonwidget(
              run:
                  () =>
                      loginuserwithemailpassword(), // Pass context to the login function
              input: "Login",
            ),
            SizedBox(width: 10),
            Secondarybuttonwidget(
              run:
                  () => register(
                    context,
                  ), // Pass context to the register function
              input: "Register",
            ),
          ],
        ),
      ],
    );
  }
}
