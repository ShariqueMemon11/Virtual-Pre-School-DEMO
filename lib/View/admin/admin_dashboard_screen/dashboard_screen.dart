import 'package:demo_vps/View/admin/FeeChalan/FeeChalanManager.dart';
import 'package:demo_vps/View/admin/payment_slip_management/payment_slip_management_screen.dart';
import 'package:demo_vps/View/admin/admin_class_management/Class_management.dart';
import 'package:demo_vps/View/admin/complain_management/complain_management_screen.dart';
import 'package:demo_vps/View/admin/student_assign_to_class/student_class_assign.dart';
import 'package:demo_vps/View/admin/teacher_register_management/teacher_admission_list_screen.dart';
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
      studentCount = students!;
      teacherCount = teachers!;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _header(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ✅ SCROLLABLE MAIN CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _mainContent(),
                  ),
                ),

                _agenda(),
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
            onPressed: () {},
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
        const Text(
          "School Overview",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        Wrap(
          spacing: 20,
          runSpacing: 20,
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

        const SizedBox(height: 40),
        const Text(
          "Quick Access",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        Wrap(
          spacing: 20,
          runSpacing: 20,
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
              Icons.assignment,
              "Teacher Admission",
              TeacherAdmissionListScreen(),
            ),
            _dashboardCard(
              Icons.notifications,
              "Notifications",
              NotificationManagementScreen(),
            ),
            _dashboardCard(
              Icons.report_problem,
              "Complaints",
              ComplaintManagementScreen(),
            ),
            _dashboardCard(
              Icons.document_scanner,
              "Fee Chalans",
              FeeChalanListScreen(),
            ),
            _dashboardCardWithNotification(
              Icons.receipt_long,
              "Payment Slips",
              const PaymentSlipManagementScreen(),
            ),
          ],
        ),

        const SizedBox(height: 40), // 👈 prevents bottom cut-off
      ],
    );
  }

  Widget _statsCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 140,
      width: 230,
      padding: const EdgeInsets.all(18),
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
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text(title, style: const TextStyle(color: Colors.black54)),
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
        width: 230,
        padding: const EdgeInsets.all(16),
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
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const Align(
              alignment: Alignment.bottomRight,
              child: Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCardWithNotification(IconData icon, String title, Widget destination) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('payment_slips')
          .where('status', isEqualTo: 'pending_verification')
          .snapshots(),
      builder: (context, snapshot) {
        final pendingCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
        
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
          },
          child: Stack(
            children: [
              Container(
                height: 150,
                width: 230,
                padding: const EdgeInsets.all(16),
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
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ),
              if (pendingCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Text(
                      pendingCount > 99 ? '99+' : pendingCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ================= AGENDA =================
  Widget _agenda() {
    final agenda = [
      "08:00 - Check Emails",
      "09:00 - Attendance",
      "10:00 - Parent Queries",
      "11:00 - Teacher Meeting",
      "12:00 - Reports Review",
    ];

    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today's Agenda",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: agenda.length,
                  itemBuilder: (_, i) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            i.isEven
                                ? const Color(0xFFF1E9FF)
                                : const Color(0xFFFFF4D7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        agenda[i],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
