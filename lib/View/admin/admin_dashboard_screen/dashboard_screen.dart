import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_vps/controllers/dashboard_controller.dart';
import '../../../Model/user_model.dart';
import 'dashboard_view.dart';

class DashboardScreen extends StatelessWidget {
  final UserModel user;
  const DashboardScreen({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardController(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 247, 243, 243),
        body: DashboardView(user: user),
      ),
    );
  }
}
