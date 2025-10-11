import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Model/student_registration_data.dart';
import 'package:flutter/material.dart';

class StudentApplicationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 📡 Stream all student applications from Firestore
  Stream<List<StudentRegistrationData>> getApplications() {
    return _firestore
        .collection('student applications')
        .orderBy('childName', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                final model = StudentRegistrationData.fromMap(data);
                // store documentId as well if needed
                model.id = doc.id;
                return model;
              }).toList(),
        );
  }

  /// 🗑️ Delete an application by document ID
  Future<void> deleteApplication(String docId) async {
    try {
      await _firestore.collection('student applications').doc(docId).delete();
    } catch (e) {
      debugPrint('Error deleting application: $e');
    }
  }

  /// ✅ Update application status and approve student if needed
  Future<void> updateStatus({
    required BuildContext context,
    required String documentId,
    required String newStatus,
  }) async {
    final docRef = _firestore
        .collection('student applications')
        .doc(documentId);

    try {
      await docRef.update({'approval': newStatus});

      // If approved, move data to "Students" collection
      if (newStatus == "Approved") {
        final docSnapshot = await docRef.get();
        final data = docSnapshot.data();

        if (data != null) {
          await _firestore.collection('Students').doc(documentId).set({
            ...data,
            'role': 'student',
            'approvedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Application marked as $newStatus")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update: $e")));
    }
  }

  /// 🖼️ Convert base64 string to ImageProvider
  ImageProvider? decodeBase64Image(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) return null;
    try {
      if (base64Str.contains(',')) {
        base64Str = base64Str.split(',').last;
      }
      Uint8List bytes = base64Decode(base64Str);
      return MemoryImage(bytes);
    } catch (e) {
      debugPrint("Image decode error: $e");
      return null;
    }
  }

  /// 🟢 Status color helper
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
