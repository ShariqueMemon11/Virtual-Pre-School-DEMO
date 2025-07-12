import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_vps/controller/DesktopControllers/dashboard_controller.dart';
import '../../../Model/user_model.dart';
import '../../DesktopLayout/Dashboardscreen/dashboard_view.dart.dart';

class DashboardScreen extends StatelessWidget {
  final UserModel user;
  const DashboardScreen({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardController(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 230, 238),
        body: DashboardView(user: user),
      ),
    );
  }
}
