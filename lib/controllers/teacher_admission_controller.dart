import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../Model/teacher_admission_model.dart';

class TeacherAdmissionController extends GetxController {
  final FirebaseFirestore _firestore;

  /// Production Constructor
  TeacherAdmissionController() : _firestore = FirebaseFirestore.instance;

  /// Test Constructor
  TeacherAdmissionController.test(this._firestore);

  RxList<TeacherAdmissionModel> applications = <TeacherAdmissionModel>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchApplications();
  }

  /// Original app method
  void fetchApplications() async {
    try {
      isLoading(true);

      final snapshot =
          await _firestore
              .collection('teacher_applications')
              .orderBy('createdAt', descending: true)
              .get();

      applications.value =
          snapshot.docs
              .map((doc) => TeacherAdmissionModel.fromMap(doc.data()))
              .toList();
    } finally {
      isLoading(false);
    }
  }

  /// TEST-ONLY METHOD (No Get.snackbar, No orderBy errors)
  Future<void> fetchApplicationsForTest() async {
    final snapshot = await _firestore.collection('teacher_applications').get();

    applications.value =
        snapshot.docs
            .map((doc) => TeacherAdmissionModel.fromMap(doc.data()))
            .toList();
  }
}
