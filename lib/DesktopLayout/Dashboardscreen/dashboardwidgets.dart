import 'package:demo_vps/DesktopLayout/Dashboardscreen/mainside.dart';
import 'package:demo_vps/DesktopLayout/Dashboardscreen/sidemenu.dart';
import 'package:demo_vps/DesktopLayout/Dashboardscreen/siderow.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_vps/DesktopLayout/loginscreen/loginwidgets.dart';
import 'package:demo_vps/DesktopLayout/loginscreen/loginscreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  bool _isMenuOpen = false;

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
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _isMenuOpen = !_isMenuOpen;
                      });
                    },
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications, color: Colors.black),
                ),
                SizedBox(width: 15.w),
                Container(
                  padding: EdgeInsets.all(2), // border width
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      236,
                      33,
                      243,
                    ), // border color
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 19, // size of the circle
                    backgroundImage: AssetImage(
                      'assets/images/profilepicexample.jpg',
                    ), // or use NetworkImage(...)
                  ),
                ),

                SizedBox(width: 15.w),
              ],
            ),
          ),
        ),

        // Main content with conditional sidebar
        Expanded(
          flex: 12,
          child: Row(
            children: [
              if (_isMenuOpen) Expanded(flex: 1, child: SideMenu()),
              Expanded(flex: 5, child: MainSide()),
              Expanded(flex: 2, child: SideRow()),
            ],
          ),
        ),
      ],
    );
  }
}
