import 'package:demo_vps/View/DesktopLayout/admin/student_register_management/student_application_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../Model/student_registration_data.dart';
import '../../../../controller/DesktopControllers/admin_student_application_controller.dart';

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
        title: const Text(
          "Student Applications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 156, 129, 219),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<StudentRegistrationData>>(
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
            padding: EdgeInsets.all(16.w),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              final photo = _controller.decodeBase64Image(app.childPhotoFile);
              final status =
                  app.policyAccepted == true ? "Approved" : "Pending";

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 8.h),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12.w),
                  leading: CircleAvatar(
                    radius: 28.w,
                    backgroundImage: photo,
                    backgroundColor: const Color.fromARGB(
                      255,
                      156,
                      129,
                      219,
                      // ignore: deprecated_member_use
                    ).withOpacity(0.3),
                    child:
                        photo == null
                            ? Text(
                              app.childName?.isNotEmpty == true
                                  ? app.childName![0].toUpperCase()
                                  : "?",
                              style: const TextStyle(color: Colors.white),
                            )
                            : null,
                  ),
                  title: Text(
                    app.childName ?? "Unknown",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.email ?? "No email"),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 5.w),
                          Text(
                            app.dateOfBirth
                                    ?.toIso8601String()
                                    .split("T")
                                    .first ??
                                "N/A",
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status color chip
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _controller
                              .getStatusColor(status)
                              // ignore: deprecated_member_use
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
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _controller.deleteApplication(app.id ?? "");
                          // ignore: use_build_context_synchronously
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
