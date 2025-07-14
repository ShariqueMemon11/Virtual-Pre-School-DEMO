import 'package:flutter/material.dart';
import '../../../Model/student_registration_data.dart';

class StudentRegistrationStep1 extends StatefulWidget {
  final StudentRegistrationData registrationData;
  final VoidCallback onNext;

  const StudentRegistrationStep1({
    Key? key,
    required this.registrationData,
    required this.onNext,
  }) : super(key: key);

  @override
  State<StudentRegistrationStep1> createState() => _StudentRegistrationStep1State();
}

class _StudentRegistrationStep1State extends State<StudentRegistrationStep1> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  DateTime? _selectedDate;
  final _homePhoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _motherCellController = TextEditingController();
  final _fatherCellController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _homePhoneController.dispose();
    _emailController.dispose();
    _motherCellController.dispose();
    _fatherCellController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleNext() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      widget.registrationData.childName = _nameController.text.trim();
      widget.registrationData.age = _ageController.text.trim();
      widget.registrationData.dateOfBirth = _selectedDate;
      widget.registrationData.homePhone = _homePhoneController.text.trim();
      widget.registrationData.email = _emailController.text.trim();
      widget.registrationData.motherCell = _motherCellController.text.trim();
      widget.registrationData.fatherCell = _fatherCellController.text.trim();
      widget.onNext();
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date of birth.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name of Child'),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'MM/DD/YYYY',
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: _selectedDate == null
                        ? ''
                        : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                  ),
                  validator: (_) => _selectedDate == null ? 'Required' : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _homePhoneController,
              decoration: const InputDecoration(labelText: 'Home Phone Number'),
              keyboardType: TextInputType.phone,
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _motherCellController,
              decoration: const InputDecoration(labelText: 'Mother Cell Phone'),
              keyboardType: TextInputType.phone,
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fatherCellController,
              decoration: const InputDecoration(labelText: 'Father Cell Phone'),
              keyboardType: TextInputType.phone,
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _handleNext,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 