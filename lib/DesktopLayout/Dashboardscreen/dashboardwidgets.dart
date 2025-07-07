import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_vps/DesktopLayout/loginscreen/loginwidgets.dart';
import 'package:demo_vps/DesktopLayout/loginscreen/loginscreen.dart';

class StudentDetailsWidget extends StatelessWidget {
  final String name;
  final String phone;
  final String address;
  final String email;

  const StudentDetailsWidget({
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Dashboard',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8C5FF5),
            ),
          ),
          SizedBox(height: 32),
          _buildDetailRow('Name', name),
          SizedBox(height: 16),
          _buildDetailRow('Phone', phone),
          SizedBox(height: 16),
          _buildDetailRow('Address', address),
          SizedBox(height: 16),
          _buildDetailRow('Email', email),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFF8C5FF5),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF8C5FF5),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
