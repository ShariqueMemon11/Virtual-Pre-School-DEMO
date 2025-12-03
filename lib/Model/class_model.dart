import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String gradeName;
  final int capacity;
  final int studentCount;
  final List<String>? studentEnrolled;
  final String? teacher;
  final String? teacherid;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final String? classroomId;

  ClassModel({
    required this.id,
    required this.gradeName,
    required this.capacity,
    required this.studentCount,
    this.teacher,
    this.teacherid,
    this.createdAt,
    this.updatedAt,
    this.studentEnrolled,
    this.classroomId,
  });

  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ClassModel(
      id: doc.id,
      gradeName: data['gradeName'] ?? '',
      capacity: data['capacity'] ?? 0,
      studentCount: data['studentCount'] ?? 0,
      teacher: data['teacher'],
      teacherid: data['teacherid'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      studentEnrolled:
          data['studentEnrolled'] != null
              ? List<String>.from(data['studentEnrolled'])
              : [],
      classroomId: data['classroomId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gradeName': gradeName,
      'capacity': capacity,
      'studentCount': studentCount,
      'teacher': teacher,
      'teacherid': teacherid,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'studentEnrolled': studentEnrolled,
      'classroomId': classroomId,
    };
  }

  ClassModel copyWith({
    String? id,
    String? gradeName,
    int? capacity,
    int? studentCount,
    String? teacher,
    String? teacherid,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    List<String>? studentEnrolled,
    String? classroomId,
  }) {
    return ClassModel(
      id: id ?? this.id,
      gradeName: gradeName ?? this.gradeName,
      capacity: capacity ?? this.capacity,
      studentCount: studentCount ?? this.studentCount,
      teacher: teacher ?? this.teacher,
      teacherid: teacherid ?? this.teacherid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentEnrolled: studentEnrolled ?? this.studentEnrolled,
      classroomId: classroomId ?? this.classroomId,
    );
  }
}
