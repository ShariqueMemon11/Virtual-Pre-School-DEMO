import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/student_data.dart';
import '../Model/class_model.dart';

class StudentController {
  final FirebaseFirestore _firestore;

  /// Default constructor (real Firestore)
  StudentController() : _firestore = FirebaseFirestore.instance;

  /// Test constructor (fake Firestore)
  StudentController.test(this._firestore);

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
  /// GET CLASSES BY CATEGORY
  /// ─────────────────────────────────────────
  Future<List<ClassModel>> getClassesByCategory(String category) async {
    final snapshot =
        await _firestore
            .collection('classes')
            .where('category', isEqualTo: category)
            .get();

    return snapshot.docs.map((doc) => ClassModel.fromFirestore(doc)).toList();
  }

  /// ─────────────────────────────────────────
  /// ASSIGN OR UPDATE CLASS OF STUDENT SAFELY
  /// ─────────────────────────────────────────
  Future<void> assignClass({
    required String studentId,
    required String? oldClassId,
    required String newClassId,
  }) async {
    final classRef = _firestore.collection("classes").doc(newClassId);
    final studentRef = _firestore.collection("Students").doc(studentId);

    WriteBatch batch = _firestore.batch();

    // 🔹 Remove from old class ONLY if it exists
    if (oldClassId != null && oldClassId.isNotEmpty) {
      final oldRef = _firestore.collection("classes").doc(oldClassId);
      final oldDoc = await oldRef.get();

      if (oldDoc.exists) {
        batch.update(oldRef, {
          "studentEnrolled": FieldValue.arrayRemove([studentId]),
          "studentCount": FieldValue.increment(-1),
        });
      }
      // Old class doesn't exist, skip removal
    }

    // 🔹 Add to new class
    final newDoc = await classRef.get();
    if (!newDoc.exists) {
      throw Exception(
        "Cannot assign to new class $newClassId: document does not exist!",
      );
    }

    batch.update(classRef, {
      "studentEnrolled": FieldValue.arrayUnion([studentId]),
      "studentCount": FieldValue.increment(1),
    });

    // 🔹 Update student assignedClass
    batch.update(studentRef, {"assignedClass": newClassId});

    // 🔹 Commit batch
    await batch.commit();
  }

  /// ─────────────────────────────────────────
  /// GET CLASS NAME BY ID
  /// ─────────────────────────────────────────
  Future<String?> getClassName(String classId) async {
    final doc = await _firestore.collection("classes").doc(classId).get();
    if (!doc.exists) return null;
    return doc.data()?["gradeName"];
  }
}
