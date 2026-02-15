// student_assign_screen.dart
import 'package:flutter/material.dart';
import 'package:demo_vps/utils/responsive_helper.dart';
import '../../../controllers/student_assign_controller.dart';
import '../../../Model/student_data.dart';
import '../../../Model/class_model.dart';
import 'student_list_view.dart';

class StudentAssignScreen extends StatefulWidget {
  const StudentAssignScreen({super.key});

  @override
  State<StudentAssignScreen> createState() => _StudentAssignScreenState();
}

class _StudentAssignScreenState extends State<StudentAssignScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StudentController controller = StudentController();

  Map<String, String> classCategoryMap = {}; // classId -> category
  List<ClassModel> allClasses = [];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    loadClasses();
    super.initState();
  }

  Future<void> loadClasses() async {
    allClasses = await controller.getClasses();
    classCategoryMap = {for (var c in allClasses) c.id: c.category};
    setState(() {});
  }

  // Group students by category
  Map<String, List<StudentData>> groupByCategory(List<StudentData> students) {
    final Map<String, List<StudentData>> map = {
      'Playgroup': [],
      'Nursery': [],
      'Kindergarten': [],
      'Unknown': [],
    };

    for (var s in students) {
      final classId = s.assignedClass;
      if (classId != null) {
        final category = classCategoryMap[classId] ?? 'Unknown';
        map.putIfAbsent(category, () => []);
        map[category]!.add(s);
      } else {
        map['Unknown']!.add(s);
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Students",
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.fontSize(context, 20),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 142, 88, 235),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontSize: ResponsiveHelper.fontSize(context, 14)),
          controller: _tabController,
          tabs: const [Tab(text: "Assigned"), Tab(text: "Unassigned")],
        ),
      ),
      body: StreamBuilder<List<StudentData>>(
        stream: controller.getStudents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!;

          final assigned =
              students.where((s) => s.assignedClass != null).toList();
          final unassigned =
              students.where((s) => s.assignedClass == null).toList();

          final grouped = groupByCategory(assigned);

          return TabBarView(
            controller: _tabController,
            children: [
              // Assigned students grouped by category
              ListView(
                padding: EdgeInsets.all(ResponsiveHelper.padding(context, 12)),
                children:
                    grouped.entries
                        .where((e) => e.value.isNotEmpty)
                        .map(
                          (e) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  e.key,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              StudentListView(
                                students: e.value,
                                controller: controller,
                                shrinkWrap:
                                    true, // IMPORTANT for nested ListView
                              ),
                              const SizedBox(
                                height: 16,
                              ), // spacing between categories
                            ],
                          ),
                        )
                        .toList(),
              ),
              // Unassigned students
              StudentListView(students: unassigned, controller: controller),
            ],
          );
        },
      ),
    );
  }
}
