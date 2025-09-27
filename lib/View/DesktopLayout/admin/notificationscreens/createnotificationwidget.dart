import 'package:demo_vps/View/DesktopLayout/customwidgets/secondarybuttonwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/controller/DesktopControllers/create_notification_controller.dart';
import '../../customwidgets/dropdownselectorwidget.dart';
import '../../customwidgets/inputfieldareawidget.dart';
import '../../customwidgets/inputfieldwidget.dart';
import '../../customwidgets/primarybuttonwidget.dart';
import '../../customwidgets/uploadfilewidget.dart';

class CreateNotificationWidget extends StatefulWidget {
  const CreateNotificationWidget({super.key});

  @override
  State<CreateNotificationWidget> createState() =>
      _CreateNotificationWidgetState();
}

class _CreateNotificationWidgetState extends State<CreateNotificationWidget> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  late CreateNotificationController _controller;

  final List<String> _audienceOptions = [
    'Select Audience',
    'Students/Parents',
    'Teachers',
    'Admins',
  ];

  @override
  void initState() {
    super.initState();
    _controller = CreateNotificationController(
      titleController: _titleController,
      bodyController: _bodyController,
      context: context,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Container(
        height: screenSize.height * 1,
        width: screenSize.width * 0.4,
        padding: EdgeInsets.all(screenSize.width * 0.01),
        decoration: BoxDecoration(
          color: const Color.fromARGB(141, 233, 233, 233),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 7,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Create Notification",
              style: TextStyle(
                fontSize: 50.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 50.h),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.02,
              ),
              child: Column(
                children: [
                  InputFieldWidget(
                    input: "Notification Title",
                    controller: _titleController,
                  ),
                  SizedBox(height: 20.h),
                  InputFieldAreaWidget(
                    input: "Notification Body",
                    controller: _bodyController,
                  ),
                  SizedBox(height: 20.h),
                  DropdownSelectorWidget(
                    options: _audienceOptions,
                    selectedOption: _controller.audience ?? "Select Audience",
                    onChanged: (value) {
                      setState(() {
                        _controller.audience = value;
                      });
                    },
                  ),

                  SizedBox(height: 20.h),
                  UploadFileWidget(
                    onFilePicked: () async {
                      await _controller.handleFileUpload();
                      setState(() {}); // Refresh UI to show file name
                    },
                    fileName: _controller.fileName,
                  ),
                  SizedBox(height: 40.h),
                  Row(
                    children: [
                      Primarybuttonwidget(
                        input: "Create Notification",
                        run:
                            _controller.isSubmitting
                                ? null
                                : () {
                                  _controller.submitNotification(
                                    () => setState(() {}),
                                  );
                                },
                      ),
                      SizedBox(width: 20.w),
                      Secondarybuttonwidget(
                        run: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                        input: "Back",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
