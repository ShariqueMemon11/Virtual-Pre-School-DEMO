// lib/Model/class_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String gradeName;
  final int capacity;
  final int studentCount;
  final String? teacher;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  ClassModel({
    required this.id,
    required this.gradeName,
    required this.capacity,
    required this.studentCount,
    this.teacher,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory to create ClassModel from a Firestore DocumentSnapshot
  factory ClassModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};

    return ClassModel(
      id: doc.id,
      gradeName: data['gradeName'] as String? ?? '',
      capacity:
          (data['capacity'] is int)
              ? data['capacity'] as int
              : int.tryParse('${data['capacity']}') ?? 0,
      studentCount:
          (data['studentCount'] is int)
              ? data['studentCount'] as int
              : int.tryParse('${data['studentCount']}') ?? 0,
      teacher: data['teacher'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  /// Convert the model to a map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'gradeName': gradeName,
      'capacity': capacity,
      'studentCount': studentCount,
      'teacher': teacher,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Helpful copyWith for updates
  ClassModel copyWith({
    String? id,
    String? gradeName,
    int? capacity,
    int? studentCount,
    String? teacher,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      gradeName: gradeName ?? this.gradeName,
      capacity: capacity ?? this.capacity,
      studentCount: studentCount ?? this.studentCount,
      teacher: teacher ?? this.teacher,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
