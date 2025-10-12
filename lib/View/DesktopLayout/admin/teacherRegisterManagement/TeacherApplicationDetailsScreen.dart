// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

/// ----------------- Detail Screen -----------------
class TeacherApplicationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> application;
  const TeacherApplicationDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final details = {
      "Name": application['name'],
      "Email": "john.smith@example.com",
      "Phone": "+1 234 567 890",
      "Address": "123 Main Street, Springfield",
      "Qualification": "Master's in Education",
      "Experience": application['experience'],
      "Subject Specialization": application['subject'],
    };

    return Scaffold(
      body: Column(
        children: [
          HeaderWidget(title: "Application Details"),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                ...details.entries.map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(entry.value, style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Application Approved ✅")),
                        );
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.check),
                      label: Text("Approve"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Application Rejected ❌")),
                        );
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close),
                      label: Text("Reject"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
