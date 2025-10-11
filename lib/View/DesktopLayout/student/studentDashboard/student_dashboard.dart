import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_vps/controller/DesktopControllers/dashboard_controller.dart';
import 'dashboard_sidebar.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardController>(context);

    return Scaffold(
      body: Row(
        children: [
          // Left docked sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: controller.isMenuOpen ? 220 : 0,
            child:
                controller.isMenuOpen
                    ? const SideMenu()
                    : const SizedBox.shrink(),
          ),

          // Right content area
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  height: 56,
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

                // Main content placeholder
                Expanded(child: Container(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
