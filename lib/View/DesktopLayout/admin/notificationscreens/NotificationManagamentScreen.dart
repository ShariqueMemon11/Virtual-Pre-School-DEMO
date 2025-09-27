import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "createnotificationscreen.dart";

/// ------------------ HEADER ------------------
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
            "Notification Management",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateNotificationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text("Create"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------ LIST OF ISSUED NOTIFICATIONS ------------------
class NotificationIssuedList extends StatelessWidget {
  const NotificationIssuedList({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final notifications = [
      {
        "title": "Exam Schedule Released",
        "body": "The exam timetable for midterms is now available.",
        "audience": "Students/Parents",
        "date": "2025-08-19",
      },
      {
        "title": "Staff Meeting",
        "body":
            "All teachers are required to attend the staff meeting tomorrow.",
        "audience": "Teachers",
        "date": "2025-08-18",
      },
      {
        "title": "System Maintenance",
        "body": "Admin portal will be under maintenance this weekend.",
        "audience": "Admins",
        "date": "2025-08-17",
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notif = notifications[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: ListTile(
            leading: Icon(Icons.notifications, color: Colors.deepPurple),
            title: Text(
              notif["title"]!,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                Text(notif["body"]!, style: TextStyle(fontSize: 14.sp)),
                SizedBox(height: 4.h),
                Text("Audience: ${notif["audience"]}"),
                Text("Date: ${notif["date"]}"),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    // Navigate to CreateNotificationScreen in "edit" mode
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Edit ${notif["title"]}")),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Deleted ${notif["title"]}")),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ------------------ MAIN SCREEN ------------------
class NotificationManagementScreen extends StatelessWidget {
  const NotificationManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const HeaderWidget(),
          Expanded(child: NotificationIssuedList()),
        ],
      ),
    );
  }
}
