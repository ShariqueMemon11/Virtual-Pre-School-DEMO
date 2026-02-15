import 'package:demo_vps/View/admin/FeeChalan/FeeChalanManager.dart';
import 'package:demo_vps/View/admin/admin_class_management/Class_management.dart';
import 'package:demo_vps/View/admin/gradebook/grade_expanded.dart';
import 'package:demo_vps/View/admin/student_assign_to_class/student_class_assign.dart';
import 'package:demo_vps/View/admin/student_register_management/student_application_view.dart';
import 'package:demo_vps/View/admin/teacher_register_management/teacher_admission_list_screen.dart';
import 'package:demo_vps/View/admin/student_attendance/admin_view_attendance.dart';
import 'package:demo_vps/View/login_screen/login_screen.dart';
import 'package:demo_vps/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:demo_vps/View/admin/notification_screens/notification_managament_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getStudentCount() async {
    final snapshot = await _firestore.collection('Students').get();
    return snapshot.size;
  }

  Future<int> getTeacherCount() async {
    final snapshot = await _firestore.collection('Teachers').get();
    return snapshot.size;
  }
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isMenuOpen = true;

  int studentCount = 0;
  int teacherCount = 0;
  bool isLoading = true;

  final DashboardService _dashboardService = DashboardService();
  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final students = await _dashboardService.getStudentCount();
    final teachers = await _dashboardService.getTeacherCount();

    setState(() {
      studentCount = students;
      teacherCount = teachers;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      body: Column(
        children: [
          _header(),
          Expanded(
            child:
                isMobile
                    ? SingleChildScrollView(
                      padding: EdgeInsets.all(
                        ResponsiveHelper.padding(context, 24),
                      ),
                      child: Column(
                        children: [
                          _mainContent(),
                          SizedBox(
                            height: ResponsiveHelper.spacing(context, 20),
                          ),
                        ],
                      ),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(
                              ResponsiveHelper.padding(context, 24),
                            ),
                            child: _mainContent(),
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(color: Color(0xFF8F7CFF)),
      child: Row(
        children: [
          const SizedBox(width: 5),
          const Text(
            "Admin Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= MAIN CONTENT =================
  Widget _mainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "School Overview",
          style: TextStyle(
            fontSize: ResponsiveHelper.fontSize(context, 26),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveHelper.spacing(context, 20)),

        Wrap(
          spacing: ResponsiveHelper.spacing(context, 20),
          runSpacing: ResponsiveHelper.spacing(context, 20),
          children: [
            _statsCard(
              "Students",
              isLoading ? "..." : studentCount.toString(),
              Icons.child_care,
              const Color(0xFFF1E9FF),
            ),
            _statsCard(
              "Teachers",
              isLoading ? "..." : teacherCount.toString(),
              Icons.person,
              const Color(0xFFFFF4D7),
            ),
          ],
        ),

        SizedBox(height: ResponsiveHelper.spacing(context, 40)),
        Text(
          "Quick Access",
          style: TextStyle(
            fontSize: ResponsiveHelper.fontSize(context, 22),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveHelper.spacing(context, 20)),

        Wrap(
          spacing: ResponsiveHelper.spacing(context, 20),
          runSpacing: ResponsiveHelper.spacing(context, 20),
          children: [
            _dashboardCard(
              Icons.class_,
              "Class Management",
              ClassManagementScreen(),
            ),
            _dashboardCard(
              Icons.people,
              "Student Management",
              StudentAssignScreen(),
            ),
            _dashboardCard(
              Icons.article_rounded,
              "Student Applications",
              StudentApplicationView(),
            ),
            _dashboardCard(
              Icons.assignment,
              "Teacher Admission",
              TeacherAdmissionListScreen(),
            ),
            _dashboardCard(
              Icons.content_paste,
              "Final Grade Check",
              GradeOverviewExpandable(),
            ),
            _dashboardCard(
              Icons.notifications,
              "Notifications",
              NotificationManagementScreen(),
            ),
            _dashboardCard(
              Icons.document_scanner,
              "Fee Chalans",
              FeeChalanListScreen(),
            ),
            _dashboardCard(
              Icons.how_to_reg,
              "Student Attendance",
              AdminViewAttendanceScreen(),
            ),
          ],
        ),

        SizedBox(height: ResponsiveHelper.spacing(context, 40)),
      ],
    );
  }

  Widget _statsCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 140,
      width: ResponsiveHelper.cardWidth(context),
      padding: EdgeInsets.all(ResponsiveHelper.padding(context, 18)),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(context, 26),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.black54,
              fontSize: ResponsiveHelper.fontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard(IconData icon, String title, Widget destination) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
      },
      child: Container(
        height: 150,
        width: ResponsiveHelper.cardWidth(context),
        padding: EdgeInsets.all(ResponsiveHelper.padding(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveHelper.fontSize(context, 14),
              ),
            ),
            const Align(
              alignment: Alignment.bottomRight,
              child: Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}
