import 'package:demo_vps/DesktopLayout/Dashboardscreen/dashboardscreen.dart';

import 'package:demo_vps/DesktopLayout/Dashboardscreen/dashboardscreen.dart';

import 'package:flutter/material.dart';

class DesktopMain extends StatefulWidget {
  const DesktopMain({super.key});

  @override
  State<DesktopMain> createState() => _DesktopMainState();
}

class _DesktopMainState extends State<DesktopMain> {
  @override
  Widget build(BuildContext context) {
    // return LoginScreen();
    return DashboardScreen(name: "", email: "", phone: "", address: "");
  }
}
