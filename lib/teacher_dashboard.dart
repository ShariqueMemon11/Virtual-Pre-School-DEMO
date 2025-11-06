import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'assign_activity.dart';
import 'start_end_class.dart';
import 'upload_material.dart';
import 'update_grades.dart';
import 'student_records.dart';
import 'view_notifications.dart';
import 'messages_page.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String teacherName = "Areeba Andleeb";
  final String teacherEmail = "areeba@previrtual.edu.pk";

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  // Add agenda item
  Future<void> _addAgendaItem() async {
    if (_taskController.text.isEmpty || _timeController.text.isEmpty) return;

    await _firestore.collection('agenda').add({
      'teacherEmail': teacherEmail,
      'task': _taskController.text.trim(),
      'time': _timeController.text.trim(),
      'createdAt': DateTime.now(),
    });

    _taskController.clear();
    _timeController.clear();

    if (mounted) {
      Future.delayed(const Duration(milliseconds: 200), () {
        Navigator.pop(context);
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agenda added successfully'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // Delete agenda item
  Future<void> _deleteAgenda(String id) async {
    await _firestore.collection('agenda').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    const Color lavender = Color(0xFFD9C3F7);
    const Color lightYellow = Color(0xFFF7EBC3);
    const Color bgColor = Color(0xFFF7F5F2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: lavender,
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFD9C3F7)),
              child: Center(
                child: Text(
                  'Teacher Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            ListTile(leading: Icon(Icons.person), title: Text('Profile')),
            ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel (Profile + Quick Access)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Teacher Profile Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/teacher.png'),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacherName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Email: $teacherEmail',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Quick Access',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Quick Access Buttons
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _quickAccessCard(
                        context,
                        Icons.video_call,
                        'Start / End Class',
                        const Color(0xFFD9C3F7),
                        const StartEndClassPage(),
                      ),
                      _quickAccessCard(
                        context,
                        Icons.assignment,
                        'Assign Activities',
                        const Color(0xFFF7EBC3),
                        const AssignActivityPage(),
                      ),
                      _quickAccessCard(
                        context,
                        Icons.upload_file,
                        'Upload Class Material',
                        const Color(0xFFB7E4C7),
                        const UploadMaterialPage(),
                      ),
                      _quickAccessCard(
                        context,
                        Icons.grade,
                        'Update Grades',
                        const Color(0xFFFFC8DD),
                        const UpdateGradesPage(),
                      ),
                      _quickAccessCard(
                        context,
                        Icons.person_search,
                        'Student Records',
                        const Color(0xFFA7C7E7),
                        const StudentRecordsPage(),
                      ),
                      _quickAccessCard(
                        context,
                        Icons.notifications,
                        'View Notifications',
                        const Color(0xFFFFE5A5),
                        const ViewNotificationsPage(),
                      ),
                      _quickAccessCard(
                        context,
                        Icons.message,
                        'Messages',
                        const Color(0xFFCDB4DB),
                        MessagesPage(teacherEmail: "areeba@previrtual.edu.pk"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            //  Right Panel (Agenda)
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Today's Agenda",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _showAddAgendaDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      //  StreamBuilder showing Firestore agendas
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('agenda')
                              .where(
                                'teacherEmail',
                                isEqualTo: 'areeba@previrtual.edu.pk',
                              )
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text("No agenda items yet."),
                              );
                            }

                            final items = snapshot.data!.docs;

                            return ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final data =
                                    items[index].data() as Map<String, dynamic>;
                                final color = index.isEven
                                    ? lavender
                                    : lightYellow;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              data['time'] ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              data['task'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () async {
                                            await _deleteAgenda(
                                              items[index].id,
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Agenda deleted successfully',
                                                ),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Quick Access Card Widget
  static Widget _quickAccessCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    Widget page,
  ) {
    return Container(
      width: 220,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  //  Add Agenda Dialog
  void _showAddAgendaDialog(BuildContext context) {
    _taskController.clear();
    _timeController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Add New Agenda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Time (e.g. 9:00 - 9:30)',
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Task (e.g. Review Homework)',
                prefixIcon: Icon(Icons.edit_note),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD9C3F7),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _addAgendaItem,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

