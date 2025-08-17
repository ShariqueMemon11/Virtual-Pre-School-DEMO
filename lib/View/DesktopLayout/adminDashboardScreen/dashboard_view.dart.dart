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
            color: const Color.fromRGBO(181, 154, 245, 1),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    controller.isMenuOpen ? Icons.arrow_back_sharp : Icons.menu,
                    color: Colors.blueGrey,
                  ),
                  onPressed: controller.toggleMenu,
                ),
                const Spacer(),
                const Icon(Icons.notifications, color: Colors.white),
                const SizedBox(width: 15),
                const CircleAvatar(
                  radius: 21,
                  backgroundImage: AssetImage(
                    'assets/images/profilepicexample.jpg',
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
