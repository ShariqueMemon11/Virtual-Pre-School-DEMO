import 'package:cloud_firestore/cloud_firestore.dart';

class GradeModel {
  final String id;
  final String subject;
  final String grade;
  final String teacherName;
  final String studentUid;

  GradeModel({
    required this.id,
    required this.subject,
    required this.grade,
    required this.teacherName,
    required this.studentUid,
  });

  factory GradeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return GradeModel(
      id: doc.id,
      subject: data['subject'] ?? '',
      grade: data['grade'] ?? '',
      teacherName: data['teacherName'] ?? '',
      studentUid: data['studentUid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'grade': grade,
      'teacherName': teacherName,
      'studentUid': studentUid,
    };
  }
}
