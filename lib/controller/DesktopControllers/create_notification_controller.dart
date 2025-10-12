// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Model/notification_modal.dart';

class CreateNotificationController {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final BuildContext context;

  String? audience;
  String? uploadedDocumentBase64;
  String? uploadedDocumentName;
  bool isSubmitting = false;

  CreateNotificationController({
    required this.titleController,
    required this.bodyController,
    required this.context,
  });

  Future<void> submitNotification(VoidCallback refreshUI) async {
    if (titleController.text.trim().isEmpty ||
        bodyController.text.trim().isEmpty ||
        audience == null ||
        audience == 'Select Audience') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      isSubmitting = true;
      refreshUI();

      final docRef =
          FirebaseFirestore.instance.collection('notifications').doc();

      final notification = NotificationModel(
        id: docRef.id,
        title: titleController.text.trim(),
        body: bodyController.text.trim(),
        audience: audience!,
        uploadedDocument: uploadedDocumentBase64,
        documentName: uploadedDocumentName,
      );

      await docRef.set(notification.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification Created Successfully!')),
      );

      // clear fields
      titleController.clear();
      bodyController.clear();
      audience = "Select Audience";
      uploadedDocumentBase64 = null;
      uploadedDocumentName = null;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      isSubmitting = false;
      refreshUI();
    }
  }
}

class NotificationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getNotificationsStream() {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteNotification(String id, BuildContext context) async {
    try {
      await _firestore.collection('notifications').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting notification: $e")),
      );
    }
  }

  Future<void> updateNotification(
    NotificationModel notification,
    BuildContext context,
  ) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .update(notification.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating notification: $e")),
      );
    }
  }

  Future<NotificationModel?> getNotificationById(String id) async {
    final doc = await _firestore.collection('notifications').doc(id).get();
    if (doc.exists) {
      return NotificationModel.fromMap(doc.data()!);
    }
    return null;
  }
}
