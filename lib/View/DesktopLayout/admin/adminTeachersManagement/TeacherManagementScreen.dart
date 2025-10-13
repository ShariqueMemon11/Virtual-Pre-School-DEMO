// ignore_for_file: file_names

import 'package:demo_vps/View/DesktopLayout/admin/adminTeachersManagement/assignTeacher/assign_teacher_screen.dart';
import 'package:demo_vps/View/DesktopLayout/admin/teacherRegisterManagement/TeacherApplicationDetailsScreen.dart';
import 'package:demo_vps/View/DesktopLayout/admin/teacherRegisterManagement/TeacherRegisterManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ----------------- HEADER -----------------
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

/// ----------------- Hired Teachers List -----------------
class HiredTeachersList extends StatelessWidget {
  const HiredTeachersList({super.key});

  @override
  Widget build(BuildContext context) {
    final hiredTeachers = [
      {
        'name': 'Ayesha Khan',
        'subject': 'English',
        'experience': '6 years',
        'assignedClass': 'Class 1A',
      },
      {
        'name': 'Bilal Ahmed',
        'subject': 'Mathematics',
        'experience': '4 years',
        'assignedClass': null,
      },
      {
        'name': 'Fatima Noor',
        'subject': 'Science',
        'experience': '7 years',
        'assignedClass': 'Class 2A',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: hiredTeachers.length,
      itemBuilder: (context, index) {
        final teacher = hiredTeachers[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: ListTile(
            title: Text(
              teacher['name']!,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Subject: ${teacher['subject']}"),
                Text("Experience: ${teacher['experience']}"),
                Text(
                  teacher['assignedClass'] != null
                      ? "Assigned to: ${teacher['assignedClass']}"
                      : "Not Assigned",
                  style: TextStyle(
                    color:
                        teacher['assignedClass'] != null
                            ? Colors.green
                            : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 18.sp),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => TeacherApplicationDetailScreen(
                        application: {
                          "name": teacher['name'],
                          "subject": teacher['subject'],
                          "experience": teacher['experience'],
                          "status": "Hired",
                        },
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// ----------------- MAIN TEACHER MANAGEMENT SCREEN -----------------
class TeacherManagementScreen extends StatelessWidget {
  const TeacherManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const HeaderWidget(title: "Teacher Management"),
          Expanded(
            child: Column(
              children: [
                // Navigation Buttons
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AssignTeacherScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.assignment_ind),
                        label: Text("Assign Teacher"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TeacherRegisterManagement(),
                            ),
                          );
                        },
                        icon: Icon(Icons.app_registration),
                        label: Text("Applications"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Hired Teachers Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Text(
                          "Hired Teachers",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      Expanded(child: HiredTeachersList()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
