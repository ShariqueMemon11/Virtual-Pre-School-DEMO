import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

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
            "Teacher Application Management",
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
    // Sample teacher applications data
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
              // Show details in a dialog instead of new screen
              _showApplicationDetails(context, app);
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

  void _showApplicationDetails(BuildContext context, Map<String, dynamic> app) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Application Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name: ${app['name']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text('Subject: ${app['subject']}'),
                SizedBox(height: 8.h),
                Text('Experience: ${app['experience']}'),
                SizedBox(height: 8.h),
                Text(
                  'Status: ${app['status']}',
                  style: TextStyle(color: _getStatusColor(app['status'])),
                ),
              ],
            ),
            actions: [
              if (app['status'] == 'Pending') ...[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Reject', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Approve', style: TextStyle(color: Colors.green)),
                ),
              ],
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }
}

class TeacherRegisterManagement extends StatelessWidget {
  const TeacherRegisterManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const HeaderWidget(),
          Expanded(child: TeacherApplicationList()),
        ],
      ),
    );
  }
}
