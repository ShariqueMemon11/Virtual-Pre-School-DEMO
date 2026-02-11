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
  final int classFee;
  final String category; // Playgroup | Nursery | Kindergarten

  ClassModel({
    required this.id,
    required this.gradeName,
    required this.capacity,
    required this.studentCount,
    required this.classFee,
    required this.category,
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
      classFee: data['classFee'] ?? 0,
      category: data['category'] ?? '',
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
      'classFee': classFee,
      'category': category,
    };
  }

  ClassModel copyWith({
    String? id,
    String? gradeName,
    int? capacity,
    int? studentCount,
    int? classFee,
    String? teacher,
    String? teacherid,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    List<String>? studentEnrolled,
    String? classroomId,
    String? category,
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
      classFee: classFee ?? this.classFee,
      category: category ?? this.category,
    );
  }
}
