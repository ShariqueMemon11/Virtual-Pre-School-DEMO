// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../controllers/create_notification_controller.dart';
import 'create_notification_screen.dart';
import 'edit_notification_view.dart';
import 'view_notification_view.dart';

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
                  builder: (_) => const CreateNotificationWebView(),
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

/// ------------------ LIST OF NOTIFICATIONS ------------------
class NotificationIssuedList extends StatelessWidget {
  final NotificationController controller = NotificationController();
  NotificationIssuedList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.getNotificationsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No notifications found.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final notifications = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final doc = notifications[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: EdgeInsets.only(bottom: 12.h),
              child: ListTile(
                leading: const Icon(
                  Icons.notifications,
                  color: Colors.deepPurple,
                ),
                title: Text(
                  data["title"] ?? "Untitled",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.h),
                    Text(data["body"] ?? "", style: TextStyle(fontSize: 14.sp)),
                    SizedBox(height: 4.h),
                    Text("Audience: ${data["audience"] ?? 'N/A'}"),
                    Text(
                      "Date: ${data["createdAt"] != null ? (data["createdAt"].toDate().toString().split(' ')[0]) : 'Unknown'}",
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewNotificationView(id: doc.id),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditNotificationView(id: doc.id),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed:
                          () => controller.deleteNotification(doc.id, context),
                    ),
                  ],
                ),
              ),
            );
          },
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
