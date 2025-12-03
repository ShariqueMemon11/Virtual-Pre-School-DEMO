// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../assignments/assignments_modal.dart';
import '../grades/grades_modal.dart';
import '../materials/materials_modal.dart';
import 'dart:convert';

typedef FirestoreGrade = Map<String, dynamic>;

class StudentDashboardMain extends StatefulWidget {
  const StudentDashboardMain({super.key});

  @override
  State<StudentDashboardMain> createState() => _StudentDashboardMainState();
}

class _StudentDashboardMainState extends State<StudentDashboardMain> {
  String? studentName;
  String? studentEmail;
  String? studentImageBase64;
  String? studentClassName;
  String? studentClassId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // First try to get from Students collection
        final studentsQuery =
            await FirebaseFirestore.instance
                .collection('Students')
                .where('email', isEqualTo: user.email)
                .limit(1)
                .get();

        if (studentsQuery.docs.isNotEmpty) {
          final studentData = studentsQuery.docs.first.data();

          setState(() {
            studentName = studentData['childName'] ?? 'Student';
            studentEmail = studentData['email'] ?? user.email;
            studentImageBase64 = studentData['childPhotoFile'];
            studentClassName =
                studentData['assignedClass'] ??
                studentData['className'] ??
                studentData['class'];
            studentClassId =
                studentData['assignedClassId'] ??
                studentData['assignedClass'] ??
                studentData['classId'];
            isLoading = false;
          });
          return;
        }

        // If not found in Students, try student applications collection
        final applicationsQuery =
            await FirebaseFirestore.instance
                .collection('student applications')
                .where('email', isEqualTo: user.email)
                .limit(1)
                .get();

        if (applicationsQuery.docs.isNotEmpty) {
          final studentData = applicationsQuery.docs.first.data();

          setState(() {
            studentName = studentData['childName'] ?? 'Student';
            studentEmail = studentData['email'] ?? user.email;
            studentImageBase64 = studentData['childPhotoFile'];
            studentClassName =
                studentData['assignedClass'] ??
                studentData['className'] ??
                studentData['class'];
            studentClassId =
                studentData['assignedClassId'] ??
                studentData['assignedClass'] ??
                studentData['classId'];
            isLoading = false;
          });
          return;
        }

        // If no data found, use Firebase user data
        setState(() {
          studentName = user.displayName ?? 'Student';
          studentEmail = user.email ?? 'No email';
          studentImageBase64 =
              user.photoURL; // This will be null for base64, but we handle it in UI
          studentClassName = null;
          studentClassId = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        studentName = 'Student';
        studentEmail = 'No email';
        studentImageBase64 = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                child: Text(
                  "Student Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.sp,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 22.0, right: 42),
                child: Divider(thickness: 0.5, color: Colors.blueGrey),
              ),

              // Student Profile Card
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStudentProfileCard(),
                    _buildStudentProgressCard(),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 20.0),
                child: Text(
                  "Quick Access",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.sp,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 22.0, right: 42),
                child: Divider(thickness: 0.5, color: Colors.blueGrey),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildQuickAccessCard(
                      icon: Icons.schedule,
                      label: "Join Class",
                      color: const Color.fromARGB(255, 249, 236, 184),
                      onTap: _joinLiveClass, // ✅ ADD THIS
                    ),
                    SizedBox(width: 50.w),

                    _buildQuickAccessCard(
                      icon: Icons.grade,
                      label: "My Grades",
                      color: const Color.fromARGB(255, 212, 248, 238),
                      onTap: _showGradesModal,
                    ),
                    SizedBox(width: 50.w),

                    _buildQuickAccessCard(
                      icon: Icons.assignment,
                      label: "My Assignments",
                      color: const Color.fromARGB(255, 238, 212, 248),
                      onTap: _showAssignmentsModal,
                    ),
                    SizedBox(width: 50.w),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildQuickAccessCard(
                      icon: Icons.folder_copy_outlined,
                      label: "Class Materials",
                      color: const Color.fromARGB(255, 238, 212, 248),
                      onTap: _showClassMaterialsModal,
                    ),
                    SizedBox(width: 50.w),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider? _getImageProvider() {
    if (studentImageBase64 != null && studentImageBase64!.isNotEmpty) {
      // Check if it's a base64 string
      if (studentImageBase64!.startsWith('data:image/') ||
          studentImageBase64!.startsWith('/9j/') ||
          studentImageBase64!.startsWith('iVBORw0KGgo') ||
          studentImageBase64!.startsWith('UklGR')) {
        try {
          // Handle base64 image
          final base64String =
              studentImageBase64!.contains(',')
                  ? studentImageBase64!.split(',')[1]
                  : studentImageBase64!;
          final bytes = base64Decode(base64String);
          return MemoryImage(bytes);
        } catch (e) {
          return null;
        }
      } else if (studentImageBase64!.startsWith('http')) {
        // Handle network URL

        return NetworkImage(studentImageBase64!);
      } else {}
    } else {}
    return null;
  }

  Widget _buildStudentImage() {
    final imageProvider = _getImageProvider();

    if (imageProvider != null) {
      return CircleAvatar(
        radius: 50.r,
        backgroundColor: const Color.fromARGB(255, 151, 123, 218),
        backgroundImage: imageProvider,
        child: null,
      );
    } else {
      return CircleAvatar(
        radius: 50.r,
        backgroundColor: const Color.fromARGB(255, 151, 123, 218),
        child: Icon(Icons.person, size: 50.sp, color: Colors.white),
      );
    }
  }

  Widget _buildStudentProfileCard() {
    if (isLoading) {
      return Container(
        height: 160.h,
        width: 500.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 160.h,
      width: 500.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Student Image
            _buildStudentImage(),
            SizedBox(width: 20.w),

            // Student Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    studentName ?? 'Student',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.sp,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    studentEmail ?? 'No email',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Student',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color.fromARGB(255, 151, 123, 218),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // (Removed unused helper _buildProgressCircleWithRemark)

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$label - Coming Soon!')));
          },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 160.h,
          width: 230.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28.sp, color: Colors.black87),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_circle_right, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignmentsModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const AssignmentsModal();
      },
    );
  }

  void _showGradesModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const GradesModal();
      },
    );
  }

  void _showClassMaterialsModal() {
    if ((studentClassId == null || studentClassId!.isEmpty) &&
        (studentClassName == null || studentClassName!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Class not assigned yet. Please contact your teacher/admin.',
          ),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ClassMaterialsModal(
          classId: studentClassId,
          className: studentClassName,
        );
      },
    );
  }

  // Replace _buildStudentProgressCard body with fetch from Firestore
  Widget _buildStudentProgressCard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchStudentGrades(),
      builder: (context, snapshot) {
        final grades = snapshot.data ?? <Map<String, dynamic>>[];
        double avg = 0.0;
        if (grades.isNotEmpty) {
          final percentGrades = grades.map(
            (g) => _gradeToPercent(g['grade'] ?? 0),
          );
          avg =
              percentGrades.isNotEmpty
                  ? percentGrades.reduce((a, b) => a + b) / percentGrades.length
                  : 0.0;
        }
        String remark;
        String advice;
        Color color;
        if (avg >= 85) {
          remark = 'Excellent';
          advice = 'Outstanding work. Keep it up!';
          color = Colors.green;
        } else if (avg >= 70) {
          remark = 'Good';
          advice = 'You are doing good but you can improve.';
          color = Colors.orange[700]!;
        } else {
          remark = 'Needs Improvement';
          advice = 'Let’s focus on raising your grades!';
          color = Colors.redAccent;
        }
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          elevation: 3,
          margin: EdgeInsets.only(left: 36.w),
          child: Container(
            height: 160.h,
            width: 320.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 18.w),
            child: Row(
              children: [
                SizedBox(
                  width: 90.w,
                  height: 95.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: avg / 100.0,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                      Center(
                        child: Text(
                          '${avg.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 22.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        remark,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: color,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        advice,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchStudentGrades() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final gradesSnap =
        await FirebaseFirestore.instance
            .collection('grades')
            .where('studentUid', isEqualTo: user.uid)
            .get();
    return gradesSnap.docs.map((d) => d.data()).toList();
  }

  double _gradeToPercent(dynamic grade) {
    if (grade is num) return grade.toDouble();
    if (grade is String && double.tryParse(grade) != null)
      return double.parse(grade);
    switch (grade.toString().trim().toUpperCase()) {
      case 'A+':
        return 97;
      case 'A':
        return 94;
      case 'A-':
        return 90;
      case 'B+':
        return 87;
      case 'B':
        return 83;
      case 'B-':
        return 80;
      case 'C+':
        return 77;
      case 'C':
        return 73;
      case 'C-':
        return 70;
      case 'D+':
        return 67;
      case 'D':
        return 63;
      case 'D-':
        return 60;
      default:
        return 0;
    }
  }

  Future<void> _joinLiveClass() async {
    if (studentClassId == null || studentClassId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You are not assigned to any class.")),
      );
      return;
    }

    try {
      // Fetch class document
      final classDoc =
          await FirebaseFirestore.instance
              .collection("classes")
              .doc(studentClassId)
              .get();

      if (!classDoc.exists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Class not found.")));
        return;
      }

      final data = classDoc.data();
      final classroomId = data?["classroomId"];

      if (classroomId == null || classroomId.toString().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No live class right now.")),
        );
        return;
      }

      final student = studentName ?? "Student";

      final url = Uri.parse(
        "https://cr-puce.vercel.app/$classroomId?name=$student",
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open class link")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
