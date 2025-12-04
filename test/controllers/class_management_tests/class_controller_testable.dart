import 'package:cloud_firestore/cloud_firestore.dart';

class ClassControllerTestable {
  final FirebaseFirestore firestore;

  ClassControllerTestable(this.firestore);

  /// CREATE CLASS
  Future<void> createClass(String name, int capacity) async {
    if (name.trim().isEmpty) {
      throw Exception("Class name cannot be empty");
    }

    if (capacity <= 0) {
      throw Exception("Capacity must be greater than zero.");
    }

    await firestore.collection('classes').add({
      'gradeName': name,
      'capacity': capacity,
      'studentCount': 0,
      'teacher': null,
      'teacherid': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': null,
    });
  }

  /// UPDATE CLASS
  Future<void> updateClass(String id, String name, int capacity) async {
    if (name.trim().isEmpty) {
      throw Exception("Name empty");
    }

    await firestore.collection('classes').doc(id).update({
      'gradeName': name,
      'capacity': capacity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// DELETE CLASS
  Future<void> deleteClass(String id) async {
    await firestore.collection('classes').doc(id).delete();
  }

  /// ASSIGN TEACHER
  Future<void> assignTeacher(
    String id,
    String teacherId,
    String teacherName,
  ) async {
    await firestore.collection('classes').doc(id).update({
      'teacher': teacherName,
      'teacherid': teacherId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// UNASSIGN TEACHER
  Future<void> unassignTeacher(String id) async {
    await firestore.collection('classes').doc(id).update({
      'teacher': null,
      'teacherid': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
