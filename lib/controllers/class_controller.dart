import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../Model/class_model.dart';
import '../Model/teacher_model.dart';

class ClassController {
  // Firestore "classes" collection
  final CollectionReference _classCollection = FirebaseFirestore.instance
      .collection('classes');

  // Get all classes as stream
  Stream<List<ClassModel>> getClasses() {
    return _classCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClassModel.fromFirestore(doc);
      }).toList();
    });
  }

  // Create new class
  Future<void> createClass(String name, int capacity, int classFee) async {
    await _classCollection.add({
      'gradeName': name,
      'capacity': capacity,
      'classFee': classFee,
      'studentCount': 0,
      'teacher': null,
      'teacherid': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update class
  Future<void> updateClass(
    String id,
    String name,
    int capacity,
    int classFee,
  ) async {
    await _classCollection.doc(id).update({
      'gradeName': name,
      'capacity': capacity,
      'classFee': classFee,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete class
  Future<void> deleteClass(String id) async {
    try {
      await _classCollection.doc(id).delete();
      await Future.delayed(const Duration(milliseconds: 100));
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete class: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete class: $e');
    }
  }

  // Get teacher IDs already assigned to any class
  Stream<List<String>> getAssignedTeacherIds() {
    return _classCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['teacherid'])
          .whereType<String>()
          .toList();
    });
  }

  // Get all teachers
  Stream<List<TeacherModel>> getTeachers() {
    return FirebaseFirestore.instance.collection('Teachers').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => TeacherModel.fromFirestore(doc))
          .toList();
    });
  }

  // ⭐ Get only available (un-assigned) teachers
  Stream<List<TeacherModel>> getAvailableTeachers() {
    final teacherStream =
        FirebaseFirestore.instance.collection('Teachers').snapshots();

    return Rx.combineLatest2(teacherStream, getAssignedTeacherIds(), (
      QuerySnapshot teacherSnap,
      List<String> assignedIds,
    ) {
      return teacherSnap.docs
          .map((doc) => TeacherModel.fromFirestore(doc))
          .where((teacher) => !assignedIds.contains(teacher.id))
          .toList();
    });
  }

  // Assign a teacher
  Future<void> assignTeacher(
    String classId,
    String teacherId,
    String teacherName,
  ) async {
    await _classCollection.doc(classId).update({
      'teacher': teacherName,
      'teacherid': teacherId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Unassign teacher
  Future<void> unassignTeacher(String classId) async {
    await _classCollection.doc(classId).update({
      'teacher': null,
      'teacherid': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
