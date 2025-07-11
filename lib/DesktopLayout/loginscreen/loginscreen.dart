import 'package:demo_vps/DesktopLayout/loginscreen/loginwidgets.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(140, 95, 245, 1), // Light gray
              Color.fromARGB(255, 156, 129, 219), // Slightly lighter gray
            ],
          ),
        ),
        child: const LoginWidgets(),
      ),
    );
  }
}
