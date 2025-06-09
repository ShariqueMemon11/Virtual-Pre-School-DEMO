import 'package:demo_vps/DesktopLayout/customwidgets/dropdownselectorwidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/inputfieldareawidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/primarybuttonwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/inputfieldwidget.dart';
import 'package:demo_vps/DesktopLayout/customwidgets/uploadfilewidget.dart';

class CreateNotificationWidget extends StatefulWidget {
  const CreateNotificationWidget({super.key});
  @override
  State<CreateNotificationWidget> createState() =>
      _CreateNotificationWidgetState();
}

class _CreateNotificationWidgetState extends State<CreateNotificationWidget> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String audience = "Select Audience";
  List<String> audienceOptions = ['Students/Parents', 'Teachers', 'Admins'];
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    return Container(
      height: screenHeight * 0.85,
      width: screenWidth * 0.4,
      padding: EdgeInsets.all(screenWidth * 0.01),
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
            "Create Notification",
            style: TextStyle(
              fontSize: 50.sp,
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 50.h),

          Padding(
            padding: EdgeInsets.only(
              right: screenWidth * 0.02,
              left: screenWidth * 0.02,
            ),

            child: Column(
              children: [
                InputFieldWidget(
                  input: "Notification Title",
                  controller: _titleController,
                ),
                SizedBox(height: 20.h),
                InputFieldAreaWidget(),

                SizedBox(height: 20.h),
                Row(
                  children: [DropdownSelectorWidget(options: audienceOptions)],
                ),
                SizedBox(height: 20.h),
                Row(children: [UploadFileWidget()]),
                SizedBox(height: 40.h),
                Primarybuttonwidget(run: () {}, input: "Create Notification"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
