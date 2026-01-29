// invoice_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Invoice {
  final String studentId;
  final String studentName;
  final String classId;
  final String className;
  final int classFee;
  final Timestamp date;
  final String status;

  Invoice({
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.className,
    required this.date,
    required this.status,
    required this.classFee,
  });

  /// Convert Invoice → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'className': className,
      'classFee': classFee,
      'date': date,
      'status': status,
    };
  }

  /// Optional: Firestore → Invoice
  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      classId: map['classId'] ?? '',
      className: map['className'] ?? '',
      date: map['date'] ?? Timestamp.now(),
      status: map['status'] ?? 'pending',
      classFee: map['classFee'] ?? 0,
    );
  }
}
