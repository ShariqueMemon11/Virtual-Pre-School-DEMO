import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:demo_vps/controllers/admin_student_application_controller.dart';

/// 🧪 Fake BuildContext for SnackBars
class FakeContext extends Fake implements BuildContext {}

void main() {
  late FakeFirebaseFirestore firestore;
  late StudentApplicationController controller;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    controller = StudentApplicationController.test(firestore); // CUSTOM CTOR
  });

  /// ADD CUSTOM CONSTRUCTOR IN YOUR CONTROLLER:
  /// StudentApplicationController.test(this._firestore);

  group("StudentApplicationController Tests", () {
    test("PASS: getApplications() returns saved applications", () async {
      // ARRANGE
      await firestore.collection("student applications").add({
        "childName": "Ali",
        "email": "ali@gmail.com",
        "approval": "Pending",
      });

      // ACT
      final stream = controller.getApplications();
      final list = await stream.first;

      // ASSERT
      expect(list.length, 1);
      expect(list.first.childName, "Ali");
    });

    test("PASS: deleteApplication() removes document", () async {
      // ARRANGE
      final doc = await firestore.collection("student applications").add({
        "childName": "Sara",
        "email": "sara@test.com",
      });

      // ACT
      await controller.deleteApplication(doc.id);

      // ASSERT
      final remaining =
          await firestore.collection("student applications").get();
      expect(remaining.docs.length, 0);
    });
  });
}
