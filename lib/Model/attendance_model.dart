import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String studentId;
  final String studentName;
  final String classId;
  final String className;
  final Timestamp date;
  final String status; // 'present' or 'absent'
  final String markedBy; // Teacher ID
  final String markedByName; // Teacher name
  final Timestamp markedAt;

  Attendance({
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.className,
    required this.date,
    required this.status,
    required this.markedBy,
    required this.markedByName,
    required this.markedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'classId': classId,
      'className': className,
      'date': date,
      'status': status,
      'markedBy': markedBy,
      'markedByName': markedByName,
      'markedAt': markedAt,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      classId: map['classId'] ?? '',
      className: map['className'] ?? '',
      date: map['date'] ?? Timestamp.now(),
      status: map['status'] ?? 'absent',
      markedBy: map['markedBy'] ?? '',
      markedByName: map['markedByName'] ?? '',
      markedAt: map['markedAt'] ?? Timestamp.now(),
    );
  }
}
