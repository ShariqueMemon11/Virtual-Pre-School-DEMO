import 'package:demo_vps/DesktopLayout/Dashboardscreen/mainside.dart';
import 'package:demo_vps/DesktopLayout/Dashboardscreen/sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_vps/DesktopLayout/loginscreen/loginwidgets.dart';
import 'package:demo_vps/DesktopLayout/loginscreen/loginscreen.dart';

class StudentDetailsWidget extends StatefulWidget {
  final String name;
  final String phone;
  final String address;
  final String email;

  const StudentDetailsWidget({
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    super.key,
  });

  @override
  _StudentDetailsWidgetState createState() => _StudentDetailsWidgetState();
}

class _StudentDetailsWidgetState extends State<StudentDetailsWidget> {
  bool _isMenuOpen = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with toggle button
        Expanded(
          flex: 1,
          child: Container(
            color: Color.fromRGBO(140, 95, 245, 1),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    icon: Icon(
                      _isMenuOpen ? Icons.arrow_back_sharp : Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isMenuOpen = !_isMenuOpen;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Main content with conditional sidebar
        Expanded(
          flex: 14,
          child: Row(
            children: [
              if (_isMenuOpen) Expanded(flex: 1, child: SideMenu()),
              Expanded(flex: 6, child: MainSide()),
            ],
          ),
        ),
      ],
    );
  }
}
