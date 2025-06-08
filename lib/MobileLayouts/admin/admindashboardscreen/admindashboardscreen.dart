import 'package:demo_vps/MobileLayouts/customwidgets/dashboardheader.dart';
import 'package:demo_vps/MobileLayouts/customwidgets/dashboardoptionscontainer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  AdminDashboardScreenState createState() => AdminDashboardScreenState();
}

class AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF8C5FF5),
      body: SafeArea(
        child: Column(
          children: [
            DashboardHeader(input: "Admin"),
            const SizedBox(height: 20),
            OptionsContainer(),
          ],
        ),
      ),
    );
  }
}

class OptionsContainer extends StatelessWidget {
  const OptionsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
              child: Text(
                "Dashboard",
                style: TextStyle(
                  color: Color(0xFF8C5FF5),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Options(),
          ],
        ),
      ),
    );
  }
}

class Options extends StatelessWidget {
  const Options({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            DashboardOptionsContainer(
              icon: FontAwesomeIcons.users,
              label: "Users",
            ),
            DashboardOptionsContainer(
              icon: FontAwesomeIcons.fileAlt,
              label: "Reports",
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            DashboardOptionsContainer(
              icon: FontAwesomeIcons.markdown,
              label: "Documentation",
            ),
            DashboardOptionsContainer(
              icon: FontAwesomeIcons.userGraduate,
              label: "Students",
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            DashboardOptionsContainer(
              icon: FontAwesomeIcons.cog,
              label: "Settings",
            ),
            DashboardOptionsContainer(
              icon: FontAwesomeIcons.chartBar,
              label: "Analytics",
            ),
          ],
        ),
      ],
    );
  }
}
