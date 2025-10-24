import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/DesktopControllers/teacher_admission_controller.dart';
import 'teacher_admission_detail_view.dart';

class TeacherAdmissionListScreen extends StatelessWidget {
  final TeacherAdmissionController controller = Get.put(
    TeacherAdmissionController(),
  );

  TeacherAdmissionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color lightPurple = Color(0xFFEDE7F6);
    const Color deepPurple = Color(0xFF512DA8);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Teacher Applications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 142, 108, 221),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 65,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.applications.isEmpty) {
            return const Center(
              child: Text(
                "No applications found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.applications.length,
            itemBuilder: (context, index) {
              final app = controller.applications[index];
              return Card(
                color: lightPurple.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    app.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: deepPurple,
                    ),
                  ),
                  subtitle: Text(
                    app.email,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: deepPurple,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => TeacherAdmissionDetailView(application: app),
                      ),
                    );
                  },
                  hoverColor: lightPurple.withOpacity(0.6),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
