import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String gradeName;
  final int capacity;
  final int studentCount;
  final String? teacher;
  final String? teacherid;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  ClassModel({
    required this.id,
    required this.gradeName,
    required this.capacity,
    required this.studentCount,
    this.teacher,
    this.teacherid,
    this.createdAt,
    this.updatedAt,
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
    );
  }
}
