import 'package:demo_vps/MobileLayouts/customwidgets/primarybuttonwidget.dart';
import 'package:demo_vps/MobileLayouts/customwidgets/secondarybuttonwidget.dart';
import 'package:flutter/material.dart';
import 'package:demo_vps/MobileLayouts/customwidgets/inputfieldwidget.dart';

// Class name should be PascalCase
class Registerwidget extends StatelessWidget {
  const Registerwidget({super.key});

  void back(BuildContext context) {
    Navigator.pop(context);
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
        InputFieldWidget(input: "Name"),
        SizedBox(height: 30),
        InputFieldWidget(input: "Username"),
        SizedBox(height: 30),
        InputFieldWidget(input: "Email"),
        SizedBox(height: 30), // Added spacing
        InputFieldWidget(input: "Password"),
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
