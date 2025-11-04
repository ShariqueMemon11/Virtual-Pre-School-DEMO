import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_vps/controller/DesktopControllers/dashboard_controller.dart';
import 'package:demo_vps/Model/user_model.dart';
import 'dashboard_sidebar.dart';
import 'dashboard_main.dart';
import 'dashboard_agenda.dart';

class DashboardView extends StatelessWidget {
  final UserModel user;
  const DashboardView({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardController>(context);

    return Column(
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
                    controller.isMenuOpen ? Icons.arrow_back_sharp : Icons.menu,
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
              if (controller.isMenuOpen) Expanded(flex: 1, child: SideMenu()),
              Expanded(flex: 5, child: MainSide()),
              Expanded(flex: 2, child: Agenda()),
            ],
          ),
        ),
      ],
    );
  }
}
