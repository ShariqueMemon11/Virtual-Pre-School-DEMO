// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/student_data.dart';
import 'package:flutter/material.dart';

class StudentApplicationController {
  final FirebaseFirestore _firestore;

  /// 🔥 Main constructor (used in the app)
  StudentApplicationController() : _firestore = FirebaseFirestore.instance;

  /// 🧪 Test constructor (inject FakeFirebaseFirestore)
  StudentApplicationController.test(this._firestore);

  /// 📡 Stream student applications
  Stream<List<StudentData>> getApplications() {
    return _firestore
        .collection('student applications')
        .orderBy('childName', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                final model = StudentData.fromMap(data);
                model.id = doc.id; // attach document ID
                return model;
              }).toList(),
        );
  }

  /// 🗑 Delete application
  Future<void> deleteApplication(String docId) async {
    try {
      await _firestore.collection('student applications').doc(docId).delete();
    } catch (e) {
      debugPrint('Error deleting application: $e');
    }
  }

  /// 🔄 Update status + auto-approve student
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

      // If approved → Move application to Students collection
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

  /// 🖼 Convert base64 → ImageProvider
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

  /// 🌈 Get color based on status
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
