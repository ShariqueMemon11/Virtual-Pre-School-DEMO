import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String audience;
  final String? uploadedDocument;
  final String? documentName;
  final Timestamp? createdAt; // ✅ Add this

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.audience,
    this.uploadedDocument,
    this.documentName,
    this.createdAt, // ✅ Optional timestamp
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'audience': audience,
      'uploadedDocument': uploadedDocument,
      'documentName': documentName,
      'createdAt':
          createdAt ?? FieldValue.serverTimestamp(), // ✅ Firestore timestamp
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      audience: map['audience'] ?? '',
      uploadedDocument: map['uploadedDocument'],
      documentName: map['documentName'],
      createdAt: map['createdAt'], // ✅ Safe parsing
    );
  }
}
