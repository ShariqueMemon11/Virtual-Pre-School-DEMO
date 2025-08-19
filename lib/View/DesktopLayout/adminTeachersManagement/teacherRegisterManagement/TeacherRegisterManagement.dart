import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "./TeacherApplicationDetailsScreen.dart";

class HeaderWidget extends StatelessWidget {
  final String title;
  const HeaderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 156, 129, 219),
      width: double.infinity,
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherApplicationList extends StatelessWidget {
  const TeacherApplicationList({super.key});

  @override
  Widget build(BuildContext context) {
    final applications = [
      {
        'name': 'John Smith',
        'subject': 'Mathematics',
        'status': 'Pending',
        'experience': '5 years',
      },
      {
        'name': 'Sarah Johnson',
        'subject': 'Physics',
        'status': 'Approved',
        'experience': '8 years',
      },
      {
        'name': 'Michael Brown',
        'subject': 'Chemistry',
        'status': 'Rejected',
        'experience': '3 years',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => TeacherApplicationDetailScreen(application: app),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        app['name']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(app['status']!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          app['status']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text('Subject: ${app['subject']}'),
                  SizedBox(height: 4.h),
                  Text('Experience: ${app['experience']}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

class TeacherRegisterManagement extends StatelessWidget {
  const TeacherRegisterManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const HeaderWidget(title: "Teacher Application Management"),
          Expanded(child: TeacherApplicationList()),
        ],
      ),
    );
  }
}
