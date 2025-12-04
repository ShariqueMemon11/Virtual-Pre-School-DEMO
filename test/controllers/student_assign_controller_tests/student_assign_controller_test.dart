import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:demo_vps/controllers/student_assign_controller.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late StudentController controller;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    controller = StudentController.test(firestore);
  });

  group("StudentController Tests", () {
    test("getStudents returns students successfully", () async {
      await firestore.collection('Students').add({
        "childName": "Ali",
        "assignedClass": null,
      });

      final stream = controller.getStudents();
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.childName, "Ali");
    });

    test("getClasses returns all classes", () async {
      await firestore.collection('classes').add({
        "gradeName": "Grade 1",
        "capacity": 30,
        "studentCount": 0,
        "studentEnrolled": [],
      });

      await firestore.collection('classes').add({
        "gradeName": "Grade 2",
        "capacity": 25,
        "studentCount": 0,
        "studentEnrolled": [],
      });

      final classes = await controller.getClasses();

      expect(classes.length, 2);
      expect(classes[0].gradeName, isNotEmpty);
    });

    test("assignClass assigns student to new class", () async {
      // Setup class & student
      final studentDoc = await firestore.collection("Students").add({
        "childName": "Raza",
        "assignedClass": null,
      });

      final classDoc = await firestore.collection("classes").add({
        "gradeName": "Grade 3",
        "capacity": 30,
        "studentCount": 0,
        "studentEnrolled": [],
      });

      // Run function
      await controller.assignClass(
        studentId: studentDoc.id,
        oldClassId: null,
        newClassId: classDoc.id,
      );

      final updatedStudent =
          await firestore.collection("Students").doc(studentDoc.id).get();

      final updatedClass =
          await firestore.collection("classes").doc(classDoc.id).get();

      expect(updatedStudent["assignedClass"], classDoc.id);
      expect(updatedClass["studentEnrolled"], contains(studentDoc.id));
      expect(updatedClass["studentCount"], 1);
    });

    test(
      "assignClass removes student from old class then assigns new",
      () async {
        // Old class
        final oldClass = await firestore.collection("classes").add({
          "gradeName": "Grade A",
          "capacity": 20,
          "studentCount": 1,
          "studentEnrolled": ["s1"],
        });

        // New class
        final newClass = await firestore.collection("classes").add({
          "gradeName": "Grade B",
          "capacity": 25,
          "studentCount": 0,
          "studentEnrolled": [],
        });

        // Student
        await firestore.collection("Students").doc("s1").set({
          "childName": "Ahmed",
          "assignedClass": oldClass.id,
        });

        // Assign to new class
        await controller.assignClass(
          studentId: "s1",
          oldClassId: oldClass.id,
          newClassId: newClass.id,
        );

        final oldUpdated =
            await firestore.collection("classes").doc(oldClass.id).get();
        final newUpdated =
            await firestore.collection("classes").doc(newClass.id).get();
        final studentUpdated =
            await firestore.collection("Students").doc("s1").get();

        expect(oldUpdated["studentEnrolled"], isNot(contains("s1")));
        expect(oldUpdated["studentCount"], 0);

        expect(newUpdated["studentEnrolled"], contains("s1"));
        expect(newUpdated["studentCount"], 1);

        expect(studentUpdated["assignedClass"], newClass.id);
      },
    );

    test("getClassName returns correct grade name", () async {
      final classDoc = await firestore.collection("classes").add({
        "gradeName": "Grade 4",
        "capacity": 20,
        "studentCount": 0,
        "studentEnrolled": [],
      });

      final name = await controller.getClassName(classDoc.id);

      expect(name, "Grade 4");
    });
  });
}
