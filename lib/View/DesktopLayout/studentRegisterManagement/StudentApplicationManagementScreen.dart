import 'package:demo_vps/View/DesktopLayout/studentRegisterManagement/StudentApplicationView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Header bar with navigation
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

// Student Application List
class StudentapplicationList extends StatefulWidget {
  const StudentapplicationList({super.key});

  @override
  State<StudentapplicationList> createState() => _StudentapplicationListState();
}

class _StudentapplicationListState extends State<StudentapplicationList> {
  List<Map<String, String>> applications = [
    {
      "name": "Ali Raza",
      "status": "Pending",
      "class": "Nursery",
      "date": "12 Aug 2025",
    },
    {
      "name": "Sara Khan",
      "status": "Approved",
      "class": "Play Group",
      "date": "10 Aug 2025",
    },
    {
      "name": "John Doe",
      "status": "Rejected",
      "class": "KG",
      "date": "08 Aug 2025",
    },
    {
      "name": "Fatima Noor",
      "status": "Pending",
      "class": "Pre-Nursery",
      "date": "15 Aug 2025",
    },
    {
      "name": "Ahmed Ali",
      "status": "Approved",
      "class": "Nursery",
      "date": "11 Aug 2025",
    },
    {
      "name": "Maryam Shah",
      "status": "Pending",
      "class": "KG",
      "date": "13 Aug 2025",
    },
    {
      "name": "Bilal Hassan",
      "status": "Rejected",
      "class": "Play Group",
      "date": "09 Aug 2025",
    },
  ];

  void _deleteApplication(int index) {
    final deletedName = applications[index]["name"];
    setState(() {
      applications.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Deleted application of $deletedName"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: applications.length,
      padding: EdgeInsets.all(16.w),
      itemBuilder: (context, index) {
        final app = applications[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => StudentApplicationDetailScreen(application: app),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 6,
            margin: EdgeInsets.symmetric(vertical: 10.h),
            shadowColor: Colors.black26,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // Gradient Circle Avatar
                  Container(
                    width: 55.w,
                    height: 55.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        app["name"]![0],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),

                  // Info Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          app["name"]!,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6.h),

                        // Class + Date in one row
                        Row(
                          children: [
                            Icon(
                              Icons.child_care,
                              size: 16,
                              color: Colors.blueGrey,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              app["class"]!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 15.w),
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.blueGrey,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              app["date"]!,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),

                        // Status badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              app["status"]!,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: _getStatusColor(app["status"]!),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            app["status"]!,
                            style: TextStyle(
                              color: _getStatusColor(app["status"]!),
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteApplication(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
