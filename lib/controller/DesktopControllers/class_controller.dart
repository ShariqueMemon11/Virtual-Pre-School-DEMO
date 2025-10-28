import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Model/class_model.dart';

class ClassController {
  // Reference to the Firestore "classes" collection
  final CollectionReference _classCollection = FirebaseFirestore.instance
      .collection('classes');

  // ✅ Get all classes as a real-time stream
  Stream<List<ClassModel>> getClasses() {
    print('🔁 Listening to class stream...');
    return _classCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ClassModel.fromFirestore(doc);
      }).toList();
    });
  }

  // ✅ Create a new class
  Future<void> createClass(String name, int capacity) async {
    print('🟣 Creating class: $name, capacity: $capacity');
    try {
      await _classCollection.add({
        'gradeName': name,
        'capacity': capacity,
        'studentCount': 0,
        'teacher': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Class created successfully');
    } on FirebaseException catch (e) {
      print('❌ Firebase error during create: ${e.code} — ${e.message}');
      throw Exception('Failed to create class: ${e.message}');
    } catch (e) {
      print('❌ Unknown error during create: $e');
      throw Exception('Failed to create class: $e');
    }
  }

  // ✅ Update existing class details
  Future<void> updateClass(String id, String name, int capacity) async {
    print('🟣 Updating class ID: $id');
    try {
      await _classCollection.doc(id).update({
        'gradeName': name,
        'capacity': capacity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Class updated successfully');
    } on FirebaseException catch (e) {
      print('❌ Firebase error during update: ${e.code} — ${e.message}');
      throw Exception('Failed to update class: ${e.message}');
    } catch (e) {
      print('❌ Unknown error during update: $e');
      throw Exception('Failed to update class: $e');
    }
  }

  // ✅ Delete a class safely
  Future<void> deleteClass(String id) async {
    print('🟣 Deleting class ID: $id');
    try {
      await _classCollection.doc(id).delete();
      print('✅ Class deleted successfully');
      // optional delay so StreamBuilder UI settles smoothly
      await Future.delayed(const Duration(milliseconds: 100));
    } on FirebaseException catch (e) {
      print('❌ Firebase error during delete: ${e.code} — ${e.message}');
      throw Exception('Failed to delete class: ${e.message}');
    } catch (e) {
      print('❌ Unknown error during delete: $e');
      throw Exception('Failed to delete class: $e');
    }
  }
}
