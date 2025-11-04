import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../Model/teacher_admission_model.dart';

class TeacherAdmissionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<TeacherAdmissionModel> applications = <TeacherAdmissionModel>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchApplications();
  }

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
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch applications: $e');
    } finally {
      isLoading(false);
    }
  }
}
