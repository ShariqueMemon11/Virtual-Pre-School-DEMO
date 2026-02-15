import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_vps/controllers/dashboard_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../sidebar/dashboard_sidebar.dart';
import 'student_dashboard_main.dart';
import '../agenda/student_dashboard_agenda.dart';
import '../notifications/notifications_modal.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    _checkUnreadNotifications();
  }

  Future<void> _checkUnreadNotifications() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot =
          await FirebaseFirestore.instance.collection('notifications').get();

      bool hasUnread = false;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final String audience = (data['audience'] ?? '').toString();
        final bool isForStudents = audience.toLowerCase().contains('student');
        if (!isForStudents) continue;

        final readDocId = '${doc.id}_${user.uid}';
        final readDoc =
            await FirebaseFirestore.instance
                .collection('notification_reads')
                .doc(readDocId)
                .get();

        if (!readDoc.exists) {
          hasUnread = true;
          break;
        }
      }

      if (mounted) {
        setState(() {
          hasUnreadNotifications = hasUnread;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardController>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 243, 243),
      endDrawer: isMobile
          ? Drawer(
              width: screenWidth * 0.85,
              child: const StudentDashboardAgenda(),
            )
          : null,
      body: Column(
        children: [
          // Header
          Expanded(
            flex: 1,
            child: Container(
              color: const Color.fromARGB(255, 151, 123, 218),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(
                      controller.isMenuOpen
                          ? Icons.arrow_back_sharp
                          : Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: controller.toggleMenu,
                  ),
                  const Spacer(),
                  if (isMobile)
                    Builder(
                      builder: (context) => IconButton(
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                        icon: const Icon(Icons.calendar_today, color: Colors.white),
                      ),
                    ),
                  IconButton(
                    onPressed: () => _showNotificationsModal(context),
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications, color: Colors.white),
                        // Red dot for unread notifications
                        if (hasUnreadNotifications)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            flex: 12,
            child: isMobile
                ? const StudentDashboardMain()
                : Row(
                    children: [
                      if (controller.isMenuOpen)
                        Expanded(flex: 1, child: const SideMenu()),
                      Expanded(flex: 5, child: const StudentDashboardMain()),
                      Expanded(flex: 2, child: const StudentDashboardAgenda()),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const NotificationsModal();
      },
    ).then((_) {
      // Refresh unread status when modal is closed
      _checkUnreadNotifications();
    });
  }
}
