//Make a Better Form please
import 'package:flutter/material.dart';

import 'package:demo_vps/MobileLayouts/customwidgets/inputfieldwidget.dart';

class RegisterFormWidget1 extends StatelessWidget {
  const RegisterFormWidget1({super.key});

  void register(BuildContext context) {
    // Implement your registration logic here
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(207, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          InputFieldWidget(input: "Childs Full Name"),
          SizedBox(height: 30),
          InputFieldWidget(input: "Childs Full Age"),
          SizedBox(height: 30),
          InputFieldWidget(input: "Childs Date of Birth"),
          SizedBox(height: 30),
          InputFieldWidget(input: "Childs Grade"),
          SizedBox(height: 30),
          Text(
            "Upload Childs Birth Certificate",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8C5FF5),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              // File picker logic will go here
            },
            icon: Icon(Icons.upload_file),
            label: Text(
              'Upload File',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
