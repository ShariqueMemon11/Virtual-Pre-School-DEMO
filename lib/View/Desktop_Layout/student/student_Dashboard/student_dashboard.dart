import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_vps/controller/DesktopControllers/dashboard_controller.dart';
import 'dashboard_sidebar.dart';
import 'student_dashboard_main.dart';
import 'student_dashboard_agenda.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardController>(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 243, 243),
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
                  const Icon(Icons.notifications, color: Colors.white),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            flex: 12,
            child: Row(
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
}
