import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Model/class_model.dart';
import '../../Model/teacher_model.dart';

class ClassController {
  // Reference to the Firestore "classes" collection
  final CollectionReference _classCollection = FirebaseFirestore.instance
      .collection('classes');

  // ✅ Get all classes as a real-time stream
  Stream<List<ClassModel>> getClasses() {
    return _classCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClassModel.fromFirestore(doc);
      }).toList();
    });
  }

  // ✅ Create a new class
  Future<void> createClass(String name, int capacity) async {
    try {
      await _classCollection.add({
        'gradeName': name,
        'capacity': capacity,
        'studentCount': 0,
        'teacher': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to create class: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create class: $e');
    }
  }

  // ✅ Update existing class details
  Future<void> updateClass(String id, String name, int capacity) async {
    try {
      await _classCollection.doc(id).update({
        'gradeName': name,
        'capacity': capacity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to update class: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update class: $e');
    }
  }

  // ✅ Delete a class safely
  Future<void> deleteClass(String id) async {
    try {
      await _classCollection.doc(id).delete();
      // optional delay so StreamBuilder UI settles smoothly
      await Future.delayed(const Duration(milliseconds: 100));
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete class: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete class: $e');
    }
  }

  Stream<List<String>> getAssignedTeacherIds() {
    return _classCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['teacherid'])
          .whereType<String>()
          .toList();
    });
  }

  Stream<List<TeacherModel>> getTeachers() {
    return FirebaseFirestore.instance.collection('Teachers').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => TeacherModel.fromFirestore(doc))
          .toList();
    });
  }

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

  Future<void> unassignTeacher(String classId) async {
    await _classCollection.doc(classId).update({
      'teacher': null,
      'teacherid': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
