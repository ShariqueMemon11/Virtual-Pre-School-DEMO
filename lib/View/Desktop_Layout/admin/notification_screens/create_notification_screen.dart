// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/controller/DesktopControllers/create_notification_controller.dart';
import '../../custom_widgets/dropdown_selector_widget.dart';
import '../../custom_widgets/input_field_area_widget.dart';
import '../../custom_widgets/input_field_widget.dart';
import '../../custom_widgets/primary_button_widget.dart';
import '../../custom_widgets/secondary_button_widget.dart';
import '../../custom_widgets/upload_file_widget.dart';

class CreateNotificationWebView extends StatefulWidget {
  const CreateNotificationWebView({super.key});

  @override
  State<CreateNotificationWebView> createState() =>
      _CreateNotificationWebViewState();
}

class _CreateNotificationWebViewState extends State<CreateNotificationWebView> {
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

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 186, 151, 234),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.05,
            horizontal: screenSize.width * 0.08,
          ),
          child: Container(
            width:
                screenSize.width > 1200
                    ? screenSize.width * 0.5
                    : screenSize.width * 0.9,
            padding: EdgeInsets.all(30.w),
            decoration: BoxDecoration(
              color: const Color.fromARGB(111, 214, 214, 214),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Create Notification",
                  style: TextStyle(
                    fontSize: 40.sp,
                    color: const Color.fromARGB(221, 234, 234, 234),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(height: 40.h),

                // ====== FORM START ======
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
                SizedBox(height: 30.h),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Upload Document (Optional)",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 10.h),

                UploadFileWidget(
                  fileName: _controller.uploadedDocumentName,
                  onFilePicked: (base64, name) {
                    setState(() {
                      _controller.uploadedDocumentBase64 = base64;
                      _controller.uploadedDocumentName = name;
                    });
                  },
                ),
                SizedBox(height: 50.h),

                // ====== BUTTONS ======
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Primarybuttonwidget(
                      input:
                          _controller.isSubmitting
                              ? "Creating..."
                              : "Create Notification",
                      run:
                          _controller.isSubmitting
                              ? null
                              : () => _controller.submitNotification(
                                () => setState(() {}),
                              ),
                    ),
                    SizedBox(width: 20.w),
                    Secondarybuttonwidget(
                      run: () => Navigator.pop(context),
                      input: "Back",
                    ),
                  ],
                ),
                // ====== FORM END ======
              ],
            ),
          ),
        ),
      ),
    );
  }
}
