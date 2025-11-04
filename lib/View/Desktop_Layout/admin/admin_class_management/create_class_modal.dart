// views/create_class_modal.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../../../controller/DesktopControllers/class_controller.dart';
import '../../../../Model/class_model.dart';

class CreateClassModal extends StatefulWidget {
  final ClassModel? existingClass;
  const CreateClassModal({super.key, this.existingClass});

  @override
  State<CreateClassModal> createState() => _CreateClassModalState();
}

class _CreateClassModalState extends State<CreateClassModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _controller = ClassController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingClass != null) {
      _nameController.text = widget.existingClass!.gradeName;
      _capacityController.text = widget.existingClass!.capacity.toString();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (widget.existingClass == null) {
        await _controller.createClass(
          _nameController.text.trim(),
          int.parse(_capacityController.text.trim()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class created successfully!')),
        );
      } else {
        final id = widget.existingClass!.id;
        await _controller.updateClass(
          id,
          _nameController.text.trim(),
          int.parse(_capacityController.text.trim()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class updated successfully!')),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingClass != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  isEdit ? 'Update Class' : 'Create New Class',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Class Name',
                  prefixIcon: Icon(Icons.class_),
                ),
                validator:
                    (v) => v == null || v.isEmpty ? 'Enter class name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  prefixIcon: Icon(Icons.people),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter capacity';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _submit,
                  child:
                      _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            isEdit ? 'Update Class' : 'Create Class',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
