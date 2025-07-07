import 'package:demo_vps/DesktopLayout/loginscreen/loginscreen.dart';
import 'package:demo_vps/DesktopLayout/notificationscreens/createnotificationscreen.dart';

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
    return LoginScreen();
  }
}
