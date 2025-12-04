import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'class_controller_testable.dart';

void main() {
  group("ClassController FULL TESTS", () {
    test("PASS: create class successfully", () async {
      final firestore = FakeFirebaseFirestore();
      final controller = ClassControllerTestable(firestore);

      await controller.createClass("Grade 1", 30);

      final docs = await firestore.collection("classes").get();

      expect(docs.docs.length, 1);
      expect(docs.docs.first["gradeName"], "Grade 1");
      expect(docs.docs.first["capacity"], 30);
    });

    test("FAIL: create class without name throws exception", () async {
      final firestore = FakeFirebaseFirestore();
      final controller = ClassControllerTestable(firestore);

      expect(() async => controller.createClass("", 20), throwsException);
    });

    test("PASS: update class successfully", () async {
      final firestore = FakeFirebaseFirestore();
      final controller = ClassControllerTestable(firestore);

      // create initial class
      final docRef = await firestore.collection("classes").add({
        "gradeName": "Grade 1",
        "capacity": 30,
        "studentCount": 0,
      });

      // update
      await controller.updateClass(docRef.id, "Updated Grade", 40);

      final updated =
          await firestore.collection("classes").doc(docRef.id).get();
      expect(updated["gradeName"], "Updated Grade");
      expect(updated["capacity"], 40);
    });

    test("PASS: delete class successfully", () async {
      final firestore = FakeFirebaseFirestore();
      final controller = ClassControllerTestable(firestore);

      // Create class
      final docRef = await firestore.collection("classes").add({
        "gradeName": "Grade 1",
        "capacity": 30,
      });

      await controller.deleteClass(docRef.id);

      final remaining = await firestore.collection("classes").get();
      expect(remaining.docs.length, 0); // empty
    });

    test("PASS: assign teacher", () async {
      final firestore = FakeFirebaseFirestore();
      final controller = ClassControllerTestable(firestore);

      // Create class
      final classRef = await firestore.collection("classes").add({
        "gradeName": "Grade 2",
        "capacity": 40,
      });

      await controller.assignTeacher(classRef.id, "T123", "Mr. John");

      final doc = await firestore.collection("classes").doc(classRef.id).get();
      expect(doc["teacher"], "Mr. John");
      expect(doc["teacherid"], "T123");
    });

    test("PASS: unassign teacher", () async {
      final firestore = FakeFirebaseFirestore();
      final controller = ClassControllerTestable(firestore);

      // Create class
      final classRef = await firestore.collection("classes").add({
        "gradeName": "Grade 3",
        "capacity": 25,
        "teacher": "Miss Sara",
        "teacherid": "T999",
      });

      await controller.unassignTeacher(classRef.id);

      final doc = await firestore.collection("classes").doc(classRef.id).get();
      expect(doc["teacher"], null);
      expect(doc["teacherid"], null);
    });
  });
}
