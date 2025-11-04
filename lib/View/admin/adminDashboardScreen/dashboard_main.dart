import 'package:demo_vps/View/DesktopLayout/admin/ComplainManagement/ComplainManagementScreen.dart';
import 'package:demo_vps/View/DesktopLayout/admin/adminClassManagement/ClassManagement.dart';

import 'package:demo_vps/View/DesktopLayout/admin/notificationscreens/NotificationManagamentScreen.dart';
import 'package:demo_vps/View/DesktopLayout/admin/studentRegisterManagement/student_application_view.dart'
    show StudentApplicationView;
import 'package:demo_vps/View/DesktopLayout/admin/teacherRegisterManagement/teacher_admission_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainSide extends StatefulWidget {
  const MainSide({super.key});

  @override
  State<StatefulWidget> createState() => _MainSide();
}

class _MainSide extends State<MainSide> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                child: Text(
                  "School Body",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.sp,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 22.0, right: 42),
                child: Divider(thickness: 0.5, color: Colors.blueGrey),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    statscard(
                      color: Color.fromARGB(255, 238, 212, 248),
                      dataname: "Student",
                      ic: Icons.child_care_rounded,
                      quantity: "400",
                    ),
                    SizedBox(width: 50.w),
                    statscard(
                      color: Color.fromARGB(255, 249, 236, 184),
                      dataname: "Teacher",
                      ic: Icons.school,
                      quantity: "24",
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 20.0),
                child: Text(
                  "Quick Access",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.sp,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 22.0, right: 42),
                child: Divider(thickness: 0.5, color: Colors.blueGrey),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    DashboardCard(
                      icon: Icons.report_problem,
                      label: "Classroom Management",
                      destination: ClassManagementScreen(),
                    ),
                    SizedBox(width: 50.w),
                    DashboardCard(
                      icon: Icons.school,
                      label: "Teacher Management",
                      destination: TeacherAdmissionListScreen(),
                    ),
                    SizedBox(width: 50.w),
                    DashboardCard(
                      icon: Icons.people,
                      label: "Students Application Management",
                      destination: StudentApplicationView(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    DashboardCard(
                      icon: Icons.notifications,
                      label: "Notification Management",
                      //changing Destination to management Screen
                      destination: NotificationManagementScreen(),
                    ),
                    SizedBox(width: 50.w),
                    DashboardCard(
                      icon: Icons.report_problem,
                      label: "Complain Management!",
                      destination: ComplaintManagementScreen(),
                    ),
                    SizedBox(width: 50.w),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore: camel_case_types
class statscard extends StatelessWidget {
  const statscard({
    super.key,
    required this.color,
    required this.dataname,
    required this.ic,
    required this.quantity,
  });
  final Color color;
  final IconData ic;
  final String dataname;
  final String quantity;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.h,
      width: 230.w,
      decoration: BoxDecoration(
        color: color, // example color
        borderRadius: BorderRadius.all(Radius.circular(10.r)),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 30,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dataname,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25.sp,
                      color: Colors.black,
                    ),
                  ),

                  Icon(ic, size: 30.sp, color: Colors.black),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 30.0,
              ),

              child: Text(
                quantity,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.sp,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? destination;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.label,
    this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination!),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("This section is not available yet")),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 160.h,
          width: 230.w,
          color: Colors.white70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: Colors.black87),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_circle_right, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
