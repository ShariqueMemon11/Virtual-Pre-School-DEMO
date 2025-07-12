import 'package:demo_vps/Model/user_model.dart';
import 'package:demo_vps/View/DesktopLayout/Dashboardscreen/dashboardscreen.dart';

import 'package:demo_vps/View/DesktopLayout/Dashboardscreen/dashboardscreen.dart';

import 'package:flutter/material.dart';

class DesktopMain extends StatefulWidget {
  const DesktopMain({super.key});

  @override
  State<DesktopMain> createState() => _DesktopMainState();
}

class _DesktopMainState extends State<DesktopMain> {
  @override
  Widget build(BuildContext context) {
    final dummyUser = UserModel(
      name: 'Alice Smith',
      phone: '+1 234 567 8900',
      address: '123 Main Street, Springfield',
      email: 'alice@example.com',
    );
    // return LoginScreen();
    return DashboardScreen(user: dummyUser);
  }
}
