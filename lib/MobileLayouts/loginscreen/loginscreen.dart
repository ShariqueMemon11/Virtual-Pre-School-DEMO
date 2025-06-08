import 'package:demo_vps/MobileLayouts/loginscreen/loginwidgets.dart';
import 'package:flutter/material.dart';

// Class name should be PascalCase
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildCircle(double size, int color) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: Color(color), shape: BoxShape.circle),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        // Added Center widget
        child:
        // Added padding
        Stack(
          children: [
            // Background circles
            Positioned(
              top: -25,
              left: -50,
              child: buildCircle(170, 0xFF8C5FF5),
            ),
            Positioned(
              top: -130,
              right: -35,
              child: PhysicalModel(
                elevation: 10.0,
                color: Color(0xFF8C5FF5),
                shape: BoxShape.circle,
                child: buildCircle(335, 0xFF8C5FF5),
              ),
            ),

            Positioned(
              bottom: -40,
              left: -40,
              child: buildCircle(140, 0xFF8C5FF5),
            ),
            Positioned(
              bottom: 50,
              left: 60,
              child: PhysicalModel(
                elevation: 10.0,
                color: Color(0xFF8C5FF5),
                shape: BoxShape.circle,
                child: buildCircle(69, 0xFF8C5FF5),
              ),
            ),
            Container(padding: EdgeInsets.all(20), child: LoginWidgets()),
          ],
        ),
      ),
    );
  }
}
