import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/inputfieldwidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/primarybuttonwidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/secondarybuttonwidget.dart';

// Class name should be PascalCase
class Registerwidget extends StatelessWidget {
  const Registerwidget({super.key});

  void back(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    return Center(
      child: Container(
        padding: EdgeInsets.all(14.0.h),
        height: screenHeight * 0.75,
        width: screenWidth * 0.25,
        decoration: BoxDecoration(
          color: const Color.fromARGB(141, 233, 233, 233),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 7,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Register",
              style: TextStyle(
                fontSize: 50.sp,
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30.h),
            InputFieldWidget(input: "Username"),
            SizedBox(height: 30.h),
            InputFieldWidget(input: "Email"),
            SizedBox(height: 30.h),
            InputFieldWidget(input: "Phone"),
            SizedBox(height: 30.h),
            InputFieldWidget(input: "Password"),

            SizedBox(height: 30.h),
            Row(
              spacing: 10.w,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Primarybuttonwidget(run: () => {}, input: "Register"),
                Secondarybuttonwidget(run: () => back(context), input: "Login"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
