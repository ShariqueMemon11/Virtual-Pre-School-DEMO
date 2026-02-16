// ignore_for_file: file_names, use_build_context_synchronously

import 'package:demo_vps/View/admin/student_register_management/student_application_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Model/student_data.dart';
import '../../../controllers/admin_student_application_controller.dart';
import '../../../utils/responsive_helper.dart';

class StudentApplicationView extends StatefulWidget {
  const StudentApplicationView({super.key});

  @override
  State<StudentApplicationView> createState() => _StudentApplicationViewState();
}

class _StudentApplicationViewState extends State<StudentApplicationView> {
  final StudentApplicationController _controller =
      StudentApplicationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ResponsiveHelper.isMobile(context)
              ? "Applications"
              : "Student Applications",
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.fontSize(context, 20),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 156, 129, 219),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<StudentData>>(
        stream: _controller.getApplications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No applications found."));
          }

          final applications = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(ResponsiveHelper.padding(context, 16)),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              final status =
                  app.policyAccepted == true ? "Approved" : "Pending";

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 5,
                margin: EdgeInsets.symmetric(
                  vertical: ResponsiveHelper.padding(context, 8),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(
                    ResponsiveHelper.padding(context, 12),
                  ),

                  // ✅ Avatar with initial
                  leading: CircleAvatar(
                    radius: ResponsiveHelper.isMobile(context) ? 24 : 28.w,
                    backgroundColor: const Color.fromARGB(255, 156, 129, 219),
                    child: Text(
                      app.childName?.isNotEmpty == true
                          ? app.childName![0].toUpperCase()
                          : "?",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  title: Text(
                    app.childName ?? "Unknown",
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(context, 17),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.email ?? "No email",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.fontSize(context, 13),
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.spacing(context, 4)),
                      Row(
                        children: [
                          Icon(
                            Icons.cake,
                            size: ResponsiveHelper.fontSize(context, 16),
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: ResponsiveHelper.spacing(context, 5)),
                          Text(
                            app.dateOfBirth
                                    ?.toIso8601String()
                                    .split("T")
                                    .first ??
                                "N/A",
                            style: TextStyle(
                              fontSize: ResponsiveHelper.fontSize(context, 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.padding(context, 10),
                          vertical: ResponsiveHelper.padding(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: _controller
                              .getStatusColor(status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: _controller.getStatusColor(status),
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _controller.getStatusColor(status),
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveHelper.fontSize(context, 13),
                          ),
                        ),
                      ),
                      if (!ResponsiveHelper.isMobile(context))
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _controller.deleteApplication(app.id ?? "");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Deleted ${app.childName ?? 'application'}",
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => StudentApplicationDetailScreen(
                              documentId: app.id ?? "",
                              application: app.toMap().map(
                                (key, value) =>
                                    MapEntry(key, value?.toString() ?? ""),
                              ),
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
