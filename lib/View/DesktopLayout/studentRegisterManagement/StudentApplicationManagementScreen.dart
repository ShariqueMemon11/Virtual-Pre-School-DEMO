import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 156, 129, 219),
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context); // back navigation
            },
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          SizedBox(width: 10.w),
          Text(
            "Student Application Management",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class StudentapplicationList extends StatelessWidget {
  const StudentapplicationList({super.key});

  final List<Map<String, String>> applications = const [
    {"name": "Ali Raza", "status": "Pending"},
    {"name": "Sara Khan", "status": "Approved"},
    {"name": "John Doe", "status": "Rejected"},
    {"name": "Fatima Noor", "status": "Pending"},
    {"name": "Ahmed Ali", "status": "Approved"},
    {"name": "Maryam Shah", "status": "Pending"},
    {"name": "Bilal Hassan", "status": "Rejected"},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Text(
                app["name"]![0], // first letter
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(app["name"]!),
            subtitle: Text("Status: ${app["status"]}"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // handle tap on student application
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Clicked on ${app["name"]}")),
              );
            },
          ),
        );
      },
    );
  }
}

class Studentapplicationmanagementscreen extends StatelessWidget {
  const Studentapplicationmanagementscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [const Header(), Expanded(child: StudentapplicationList())],
      ),
    );
  }
}
