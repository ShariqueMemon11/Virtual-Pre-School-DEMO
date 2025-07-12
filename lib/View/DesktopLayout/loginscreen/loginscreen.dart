import 'package:flutter/material.dart';
import 'package:demo_vps/View/DesktopLayout/loginscreen/loginwidgets.dart';

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
              Color.fromRGBO(140, 95, 245, 1),
              Color.fromARGB(255, 156, 129, 219),
            ],
          ),
        ),
        child: const LoginWidgets(),
      ),
    );
  }
}
