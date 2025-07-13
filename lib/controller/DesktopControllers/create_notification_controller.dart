import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CreateNotificationController {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final BuildContext context;

  String? audience = "Select Audience";
  File? attachedFile;
  Uint8List? attachedFileBytes;
  String? fileName;

  bool isSubmitting = false;

  CreateNotificationController({
    required this.titleController,
    required this.bodyController,
    required this.context,
  });

  Future<void> handleFileUpload() async {
    final result = await FilePicker.platform.pickFiles(withData: kIsWeb);

    if (result != null && result.files.isNotEmpty) {
      fileName = result.files.single.name;

      if (kIsWeb) {
        attachedFileBytes = result.files.single.bytes;
      } else {
        attachedFile = File(result.files.single.path!);
      }
    }
  }

  Future<void> submitNotification(VoidCallback onStateChanged) async {
    if (titleController.text.trim().isEmpty ||
        bodyController.text.trim().isEmpty ||
        audience == null ||
        audience == "Select Audience") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    isSubmitting = true;
    onStateChanged(); // notify UI
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sending notification...')));

    await FirebaseFirestore.instance.collection('notifications').add({
      'title': titleController.text.trim(),
      'body': bodyController.text.trim(),
      'audience': audience,
      'fileName': fileName ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification sent successfully!')),
    );

    titleController.clear();
    bodyController.clear();
    fileName = null;
    attachedFile = null;
    attachedFileBytes = null;
    audience = "Select Audience";

    isSubmitting = false;
    onStateChanged(); // notify UI again to re-enable submit button
  }
}
