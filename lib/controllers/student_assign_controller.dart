import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/student_data.dart';
import '../Model/class_model.dart';

class StudentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ─────────────────────────────────────────
  /// GET ALL STUDENTS
  /// ─────────────────────────────────────────
  Stream<List<StudentData>> getStudents() {
    return _firestore.collection('Students').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return StudentData.fromMap(doc.data())..id = doc.id;
      }).toList();
    });
  }

  /// ─────────────────────────────────────────
  /// GET ALL CLASSES
  /// ─────────────────────────────────────────
  Future<List<ClassModel>> getClasses() async {
    final snapshot = await _firestore.collection('classes').get();
    return snapshot.docs.map((doc) => ClassModel.fromFirestore(doc)).toList();
  }

  /// ─────────────────────────────────────────
  /// ASSIGN OR UPDATE CLASS OF STUDENT
  /// ─────────────────────────────────────────
  Future<void> assignClass({
    required String studentId,
    required String? oldClassId,
    required String newClassId,
  }) async {
    final classRef = _firestore.collection("classes").doc(newClassId);
    final studentRef = _firestore.collection("Students").doc(studentId);

    WriteBatch batch = _firestore.batch();

    if (oldClassId != null && oldClassId.isNotEmpty) {
      final oldRef = _firestore.collection("classes").doc(oldClassId);
      batch.update(oldRef, {
        "studentEnrolled": FieldValue.arrayRemove([studentId]),
        "studentCount": FieldValue.increment(-1),
      });
    }

    batch.update(classRef, {
      "studentEnrolled": FieldValue.arrayUnion([studentId]),
      "studentCount": FieldValue.increment(1),
    });

    batch.update(studentRef, {"assignedClass": newClassId});

    await batch.commit();
  }

  Future<String?> getClassName(String classId) async {
    final doc = await _firestore.collection("classes").doc(classId).get();

    if (!doc.exists) return null;

    return doc.data()?["gradeName"];
  }
}
