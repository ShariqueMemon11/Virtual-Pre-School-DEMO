// lib/model/teacher_admission_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherAdmissionModel {
  final String name;
  final String email;
  final String phone;
  final String qualification;
  final String experience;
  final String subjects;
  final String address;
  final String cvBase64;
  final Timestamp createdAt;

  TeacherAdmissionModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.qualification,
    required this.experience,
    required this.subjects,
    required this.address,
    required this.cvBase64,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'qualification': qualification,
      'experience': experience,
      'subjects': subjects,
      'address': address,
      'cvBase64': cvBase64,
      'createdAt': createdAt,
    };
  }

  factory TeacherAdmissionModel.fromMap(Map<String, dynamic> data) {
    return TeacherAdmissionModel(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      qualification: data['qualification'] ?? '',
      experience: data['experience'] ?? '',
      subjects: data['subjects'] ?? '',
      address: data['address'] ?? '',
      cvBase64: data['cvBase64'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
