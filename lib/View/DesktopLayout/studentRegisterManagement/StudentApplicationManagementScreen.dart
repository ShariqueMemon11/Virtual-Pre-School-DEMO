import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Header extends StatelessWidget {
  Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 156, 129, 219),
      height: 60.h,

      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.arrow_back),
            style: ButtonStyle(
              iconColor: WidgetStateProperty.all(Colors.white), // white
            ),
          ),
          Text(
            "Student Application Management",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ],
      ),
    );
  }
}

class Studentapplicationmanagementscreen extends StatelessWidget {
  const Studentapplicationmanagementscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [Header()]));
  }
}
