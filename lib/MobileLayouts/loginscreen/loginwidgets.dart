import 'package:demo_vps/MobileLayouts/customwidgets/inputfieldwidget.dart';
import 'package:flutter/material.dart';
import 'package:demo_vps/MobileLayouts/registerscreen/registerscreen.dart';
import 'package:demo_vps/MobileLayouts/studentregisterform/registerform.dart';
import 'package:demo_vps/MobileLayouts/customwidgets/primarybuttonwidget.dart';
import 'package:demo_vps/MobileLayouts/customwidgets/secondarybuttonwidget.dart';

// Class name should be PascalCase
class LoginWidgets extends StatelessWidget {
  const LoginWidgets({super.key});

  // Removed the run() method as it is not used and causes a compile error.
  void login(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterForm()),
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
        InputFieldWidget(input: "Username"),
        SizedBox(height: 30), // Added spacing
        InputFieldWidget(input: "Password"),
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
              run: () => login(context), // Pass context to the login function
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
