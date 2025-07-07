import 'package:flutter/material.dart';
import 'dashboardwidgets.dart';

class DashboardScreen extends StatelessWidget {
  final String name;
  final String phone;
  final String address;
  final String email;

  const DashboardScreen({
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
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
        child: Center(
          child: StudentDetailsWidget(
            name: name,
            phone: phone,
            address: address,
            email: email,
          ),
        ),
      ),
    );
  }
}