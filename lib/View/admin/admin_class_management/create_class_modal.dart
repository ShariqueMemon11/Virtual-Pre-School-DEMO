// views/create_class_modal.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../../controllers/class_controller.dart';
import '../../../Model/class_model.dart';
import '../../../utils/responsive_helper.dart';

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
  final _feeController = TextEditingController();

  final _controller = ClassController();

  bool _loading = false;

  String? _selectedCategory;

  final List<String> _categories = ["Playgroup", "Nursery", "Kindergarten"];

  @override
  void initState() {
    super.initState();

    if (widget.existingClass != null) {
      _nameController.text = widget.existingClass!.gradeName;
      _capacityController.text = widget.existingClass!.capacity.toString();
      _feeController.text = widget.existingClass!.classFee.toString();
      _selectedCategory = widget.existingClass!.category;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select category")));
      return;
    }

    setState(() => _loading = true);

    try {
      final name = _nameController.text.trim();
      final capacity = int.parse(_capacityController.text.trim());
      final fee = int.parse(_feeController.text.trim());

      if (widget.existingClass == null) {
        await _controller.createClass(_selectedCategory!, name, capacity, fee);
      } else {
        await _controller.updateClass(
          widget.existingClass!.id,
          _selectedCategory!,
          name,
          capacity,
          fee,
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingClass != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            ResponsiveHelper.padding(context, 20),
        left: ResponsiveHelper.padding(context, 20),
        right: ResponsiveHelper.padding(context, 20),
        top: ResponsiveHelper.padding(context, 20),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// TITLE
              Text(
                isEdit ? "Update Class" : "Create New Class",
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),

              SizedBox(height: ResponsiveHelper.spacing(context, 20)),

              /// CATEGORY DROPDOWN
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items:
                    _categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                decoration: const InputDecoration(
                  labelText: "Category",
                  prefixIcon: Icon(Icons.category),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) => value == null ? "Select category" : null,
              ),

              SizedBox(height: ResponsiveHelper.spacing(context, 16)),

              /// CLASS NAME
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Class Name",
                  prefixIcon: Icon(Icons.class_),
                ),
                validator:
                    (v) => v == null || v.isEmpty ? "Enter class name" : null,
              ),

              SizedBox(height: ResponsiveHelper.spacing(context, 16)),

              /// CAPACITY
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Capacity",
                  prefixIcon: Icon(Icons.people),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter capacity";
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return "Enter valid number";
                  return null;
                },
              ),

              SizedBox(height: ResponsiveHelper.spacing(context, 16)),

              /// FEE
              TextFormField(
                controller: _feeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Class Fee",
                  prefixIcon: Icon(Icons.money),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter fee";
                  final n = int.tryParse(v);
                  if (n == null || n < 0) return "Enter valid amount";
                  return null;
                },
              ),

              SizedBox(height: ResponsiveHelper.spacing(context, 24)),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.isMobile(context) ? 45 : 50,
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
                            isEdit ? "Update Class" : "Create Class",
                            style: TextStyle(
                              fontSize: ResponsiveHelper.fontSize(context, 16),
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
