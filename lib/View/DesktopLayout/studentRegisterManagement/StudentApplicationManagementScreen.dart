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
    final deletedName = applications[index]["name"]; // save before removing
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
      padding: EdgeInsets.all(20.w),
      itemBuilder: (context, index) {
        final app = applications[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8.h),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    app["name"]![0], // first letter
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                SizedBox(width: 14.w),
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
                        ),
                      ),
                      SizedBox(height: 5.h),

                      // Class (Prep Class)
                      Row(
                        children: [
                          const Icon(
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
                        ],
                      ),
                      SizedBox(height: 4.h),

                      // Applied Date
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.blueGrey,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            app["date"]!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),

                      // Status
                      Row(
                        children: [
                          Icon(
                            Icons.info,
                            size: 16,
                            color: _getStatusColor(app["status"]!),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            app["status"]!,
                            style: TextStyle(
                              color: _getStatusColor(app["status"]!),
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteApplication(index),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ],
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
