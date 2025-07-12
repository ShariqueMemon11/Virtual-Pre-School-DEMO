import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class CreateNotificationController {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final BuildContext context;

  String? audience = "Select Audience";
  File? attachedFile;
  String? fileName;

  CreateNotificationController({
    required this.titleController,
    required this.bodyController,
    required this.context,
  });

  void handleFileUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      attachedFile = File(result.files.single.path!);
      fileName = result.files.single.name;
    }
  }

  void submitNotification() {
    if (titleController.text.trim().isEmpty ||
        bodyController.text.trim().isEmpty ||
        audience == null ||
        audience == "Select Audience") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    // Add Firebase/Database logic here if needed

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification sent successfully!')),
    );

    titleController.clear();
    bodyController.clear();
    fileName = null;
    attachedFile = null;
  }
}
