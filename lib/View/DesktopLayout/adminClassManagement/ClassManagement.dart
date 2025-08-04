// ignore: file_names
import 'package:demo_vps/View/DesktopLayout/adminClassManagement/ClassSelection.dart';
import 'package:flutter/material.dart';

class ClassManagementScreen extends StatelessWidget {
  const ClassManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 255, 230, 238),
        child: ClassSelection(),
      ),
    );
  }
}
