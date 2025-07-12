import 'package:flutter/material.dart';
import 'package:demo_vps/View/MobileLayouts/notificationscreens/createnotificationwidget.dart';

class CreateNotificationScreen extends StatelessWidget {
  const CreateNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8C5FF5), // Light gray
              Color.fromARGB(255, 156, 129, 219), // Slightly lighter gray
            ],
          ),
        ),
        child: Center(child: const CreateNotificationWidget()),
      ),
    );
  }
}
