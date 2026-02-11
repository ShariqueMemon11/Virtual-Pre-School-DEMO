// ignore_for_file: file_names

import 'package:demo_vps/Model/teacher_model.dart';
import 'package:flutter/material.dart';
import '../../../controllers/class_controller.dart';
import '../../../Model/class_model.dart';
import 'create_class_modal.dart';

class ClassManagementScreen extends StatelessWidget {
  const ClassManagementScreen({super.key});

  void _openCreateModal(BuildContext context, {ClassModel? existingClass}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateClassModal(existingClass: existingClass),
    );
  }

  void _showClassActions(
    BuildContext context,
    ClassModel c,
    ClassController controller,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.deepPurple),
                  title: const Text('Edit Class'),
                  onTap: () {
                    Navigator.pop(context);
                    _openCreateModal(context, existingClass: c);
                  },
                ),

                // ✅ ASSIGN / CHANGE
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(
                    c.teacher == null ? 'Assign Teacher' : 'Change Teacher',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _openAssignTeacher(context, controller, c);
                  },
                ),

                // ✅ UNASSIGN
                if (c.teacher != null)
                  ListTile(
                    leading: const Icon(
                      Icons.remove_circle,
                      color: Colors.orange,
                    ),
                    title: const Text('Unassign Teacher'),
                    onTap: () async {
                      Navigator.pop(context);
                      await controller.unassignTeacher(c.id);

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Teacher removed from ${c.gradeName}'),
                        ),
                      );
                    },
                  ),

                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Class'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(context, controller, c);
                  },
                ),
              ],
            ),
          ),
    );
  }

  // ✅ TEACHER PICKER MODAL
  void _openAssignTeacher(
    BuildContext context,
    ClassController controller,
    ClassModel c,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: StreamBuilder<List<String>>(
            stream: controller.getAssignedTeacherIds(),
            builder: (context, assignedSnap) {
              if (!assignedSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final assignedIds = assignedSnap.data!;

              return StreamBuilder<List<TeacherModel>>(
                stream: controller.getTeachers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // ✅ Filter here
                  final teachers =
                      snapshot.data!
                          .where(
                            (t) =>
                                !assignedIds.contains(t.id) ||
                                c.teacherid == t.id, // allow current
                          )
                          .toList();

                  if (teachers.isEmpty) {
                    return const Center(child: Text("No available teachers"));
                  }

                  return ListView(
                    children:
                        teachers.map((t) {
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(t.name),
                            subtitle: Text(t.email),
                            onTap: () async {
                              await controller.assignTeacher(
                                c.id,
                                t.id,
                                t.name,
                              );

                              if (!context.mounted) return;
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${t.name} assigned')),
                              );
                            },
                          );
                        }).toList(),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    ClassController controller,
    ClassModel c,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Class'),
            content: Text('Are you sure you want to delete "${c.gradeName}"?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await controller.deleteClass(c.id);

                  if (!context.mounted) return;

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted ${c.gradeName}')),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ClassController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Classes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 142, 88, 235),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<ClassModel>>(
        stream: controller.getClasses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No classes yet.'));
          }

          final classes = snapshot.data!;

          // 🔥 Group classes by category
          final Map<String, List<ClassModel>> grouped = {};

          for (var c in classes) {
            grouped.putIfAbsent(c.category, () => []);
            grouped[c.category]!.add(c);
          }

          final categories = ["Playgroup", "Nursery", "Kindergarten"];

          return ListView(
            padding: const EdgeInsets.all(12),
            children:
                categories.map((category) {
                  final categoryClasses = grouped[category] ?? [];

                  if (categoryClasses.isEmpty) return const SizedBox();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      childrenPadding: const EdgeInsets.only(bottom: 12),
                      title: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      children:
                          categoryClasses.map((c) {
                            return ListTile(
                              title: Text(c.gradeName),
                              subtitle: Text(
                                'Capacity: ${c.capacity} | '
                                'Students: ${c.studentCount}'
                                '${c.teacher != null ? " | Teacher: ${c.teacher}" : ""}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed:
                                    () => _showClassActions(
                                      context,
                                      c,
                                      controller,
                                    ),
                              ),
                            );
                          }).toList(),
                    ),
                  );
                }).toList(),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateModal(context),
        label: const Text('Add Class'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
