import 'package:demo_vps/MobileLayouts/registerscreen/registerwidget.dart';
import 'package:flutter/material.dart';

// Class name should be PascalCase
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
      body: Center(
        // Added Center widget
        child:
        // Added padding
        Stack(
          children: [
            // Background circles
            Positioned(
              top: -25,
              left: -10,
              child: buildCircle(130, 0xFF8C5FF5),
            ),
            Positioned(
              top: -130,
              right: -5,
              child: PhysicalModel(
                elevation: 10.0,
                color: Color(0xFF8C5FF5),
                shape: BoxShape.circle,
                child: buildCircle(260, 0xFF8C5FF5),
              ),
            ),

            Positioned(
              bottom: -20,
              left: -20,
              child: buildCircle(80, 0xFF8C5FF5),
            ),
            Positioned(
              bottom: 30,
              left: 40,
              child: PhysicalModel(
                elevation: 10.0,
                color: Color(0xFF8C5FF5),
                shape: BoxShape.circle,
                child: buildCircle(39, 0xFF8C5FF5),
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 50),
              padding: EdgeInsets.all(20),
              child: Registerwidget(),
            ),
          ],
        ),
      ),
    );
  }
}
