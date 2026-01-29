// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_vps/controllers/create_notification_controller.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 214, 216, 224),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth > 1200 ? 80.w : 20.w,
            vertical: 40.h,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: IgnorePointer(
              ignoring: _controller.isSubmitting,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_pageHeader(), SizedBox(height: 24.h), _formCard()],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= PAGE HEADER =================
  Widget _pageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create Notification",
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2B2B2B),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "Send announcements and updates to users",
          style: TextStyle(fontSize: 14.sp, color: Colors.black54),
        ),
      ],
    );
  }

  // ================= FORM CARD =================
  Widget _formCard() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 236, 234, 234),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Notification Details"),
          SizedBox(height: 24.h),

          _label("Title"),
          InputFieldWidget(
            input: "Enter notification title",
            controller: _titleController,
          ),
          SizedBox(height: 20.h),

          _label("Message"),
          InputFieldAreaWidget(
            input: "Enter notification message",
            controller: _bodyController,
          ),
          SizedBox(height: 20.h),

          _label("Audience"),
          DropdownSelectorWidget(
            options: _audienceOptions,
            selectedOption: _controller.audience ?? "Select Audience",
            onChanged: (value) {
              setState(() {
                _controller.audience = value;
              });
            },
          ),

          SizedBox(height: 32.h),
          Divider(color: Colors.grey.shade300),
          SizedBox(height: 28.h),

          _sectionTitle("Attachments (Optional)"),
          SizedBox(height: 16.h),

          UploadFileWidget(
            fileName: _controller.uploadedDocumentName,
            onFilePicked: (base64, name) {
              setState(() {
                _controller.uploadedDocumentBase64 = base64;
                _controller.uploadedDocumentName = name;
              });
            },
          ),

          SizedBox(height: 40.h),

          // ===== ACTIONS =====
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Secondarybuttonwidget(
                run: () => Navigator.pop(context),
                input: "Cancel",
              ),
              SizedBox(width: 16.w),
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
            ],
          ),
        ],
      ),
    );
  }

  // ================= SMALL HELPERS =================
  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF3A3A3A),
      ),
    );
  }
}
