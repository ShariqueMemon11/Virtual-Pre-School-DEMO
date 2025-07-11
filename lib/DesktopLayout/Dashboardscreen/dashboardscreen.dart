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
      backgroundColor: Color.fromARGB(240, 224, 206, 230),
      body: Center(
        child: StudentDetailsWidget(
          name: name,
          phone: phone,
          address: address,
          email: email,
        ),
      ),
    );
  }
}
