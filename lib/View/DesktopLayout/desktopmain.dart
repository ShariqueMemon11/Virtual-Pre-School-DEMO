import 'package:demo_vps/Model/user_model.dart';
import 'package:demo_vps/View/DesktopLayout/admin/adminDashboardScreen/dashboardscreen.dart';
import 'package:demo_vps/View/DesktopLayout/admin/adminTeachersManagement/TeacherManagementScreen.dart';
import 'package:demo_vps/View/DesktopLayout/loginscreen/loginscreen.dart';

import 'package:flutter/material.dart';
// issues shariq Side
// Register forms issues

class DesktopMain extends StatefulWidget {
  const DesktopMain({super.key});

  @override
  State<DesktopMain> createState() => _DesktopMainState();
}

//only Desktop
class _DesktopMainState extends State<DesktopMain> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final dummyUser = UserModel(
      name: 'Alice Smith',
      phone: '+1 234 567 8900',
      address: '123 Main Street, Springfield',
      email: 'alice@example.com',
    );
    return LoginScreen();
    //DashboardScreen(user: dummyUser)
  }
}
