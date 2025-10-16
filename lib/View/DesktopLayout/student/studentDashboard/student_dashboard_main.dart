import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'assignments_modal.dart';
import 'dart:convert';
import 'messages_modal.dart';

class StudentDashboardMain extends StatefulWidget {
  const StudentDashboardMain({super.key});

  @override
  State<StudentDashboardMain> createState() => _StudentDashboardMainState();
}

class _StudentDashboardMainState extends State<StudentDashboardMain> {
  String? studentName;
  String? studentEmail;
  String? studentImageBase64;
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
          print('Student data found: ${studentData.keys}');
          print(
            'Image data type: ${studentData['childPhotoFile']?.runtimeType}',
          );
          print(
            'Image data length: ${studentData['childPhotoFile']?.toString().length}',
          );
          setState(() {
            studentName = studentData['childName'] ?? 'Student';
            studentEmail = studentData['email'] ?? user.email;
            studentImageBase64 = studentData['childPhotoFile'];
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
          print('Student application data found: ${studentData.keys}');
          print(
            'Image data type: ${studentData['childPhotoFile']?.runtimeType}',
          );
          print(
            'Image data length: ${studentData['childPhotoFile']?.toString().length}',
          );
          setState(() {
            studentName = studentData['childName'] ?? 'Student';
            studentEmail = studentData['email'] ?? user.email;
            studentImageBase64 = studentData['childPhotoFile'];
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
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading student data: $e');
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
                child: _buildStudentProfileCard(),
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
                      icon: Icons.assignment,
                      label: "My Assignments",
                      color: const Color.fromARGB(255, 238, 212, 248),
                    ),
                    SizedBox(width: 50.w),
                    _buildQuickAccessCard(
                      icon: Icons.schedule,
                      label: "Join Class",
                      color: const Color.fromARGB(255, 249, 236, 184),
                    ),
                    SizedBox(width: 50.w),
                    _buildQuickAccessCard(
                      icon: Icons.grade,
                      label: "My Grades",
                      color: const Color.fromARGB(255, 212, 248, 238),
                    ),
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
                      icon: Icons.message,
                      label: "Messages",
                      color: const Color.fromARGB(255, 238, 212, 248),
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
      print(
        'Processing image data: ${studentImageBase64!.substring(0, 50)}...',
      );

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
          print('Decoding base64 string of length: ${base64String.length}');
          final bytes = base64Decode(base64String);
          print('Successfully decoded ${bytes.length} bytes');
          return MemoryImage(bytes);
        } catch (e) {
          print('Error decoding base64 image: $e');
          return null;
        }
      } else if (studentImageBase64!.startsWith('http')) {
        // Handle network URL
        print('Using network image: $studentImageBase64');
        return NetworkImage(studentImageBase64!);
      } else {
        print(
          'Unknown image format: ${studentImageBase64!.substring(0, 20)}...',
        );
      }
    } else {
      print('No image data available');
    }
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

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        if (label == 'My Assignments') {
          _showAssignmentsModal();
        } else if (label == 'Messages') {
          _showMessagesModal();
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$label - Coming Soon!')));
        }
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

  void _showMessagesModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const MessagesModal();
      },
    );
  }
}
