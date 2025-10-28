// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../../../../controller/DesktopControllers/class_controller.dart';
import '../../../../Model/class_model.dart';
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
                  await controller.deleteClass(
                    c.id,
                  ); // wait until deletion is done
                  if (!context.mounted) return; // safety check after await

                  Navigator.pop(
                    context,
                  ); // close modal only after delete finishes
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
          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final c = classes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(c.gradeName),
                  subtitle: Text(
                    'Capacity: ${c.capacity} | Students: ${c.studentCount}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showClassActions(context, c, controller),
                  ),
                ),
              );
            },
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
