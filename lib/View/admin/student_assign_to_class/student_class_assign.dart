import 'package:flutter/material.dart';
import '../../../controllers/student_assign_controller.dart';
import '../../../Model/student_data.dart';
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

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Students", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 142, 88, 235),
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          labelColor: Colors.white, // Selected tab text color
          unselectedLabelColor: Colors.white70,
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

          var students = snapshot.data!;

          final assigned =
              students.where((s) => s.assignedClass != null).toList();
          final unassigned =
              students.where((s) => s.assignedClass == null).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              StudentListView(students: assigned, controller: controller),
              StudentListView(students: unassigned, controller: controller),
            ],
          );
        },
      ),
    );
  }
}
