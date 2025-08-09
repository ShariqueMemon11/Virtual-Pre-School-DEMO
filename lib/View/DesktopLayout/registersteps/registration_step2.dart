import 'package:flutter/material.dart';
import '../../../Model/student_registration_data.dart';

class StudentRegistrationStep2 extends StatefulWidget {
  final StudentRegistrationData registrationData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StudentRegistrationStep2({
    super.key,
    required this.registrationData,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<StudentRegistrationStep2> createState() =>
      _StudentRegistrationStep2State();
}

class _StudentRegistrationStep2State extends State<StudentRegistrationStep2> {
  final _formKey = GlobalKey<FormState>();

  // Mother
  final _motherNameController = TextEditingController();
  final _motherIdController = TextEditingController();
  final _motherAddressController = TextEditingController();
  final _motherOccupationController = TextEditingController();
  final _motherWorkAddressController = TextEditingController();
  final _motherSalaryController = TextEditingController();

  // Father
  final _fatherNameController = TextEditingController();
  final _fatherIdController = TextEditingController();
  final _fatherAddressController = TextEditingController();
  final _fatherOccupationController = TextEditingController();
  final _fatherWorkAddressController = TextEditingController();
  final _fatherSalaryController = TextEditingController();

  @override
  void dispose() {
    _motherNameController.dispose();
    _motherIdController.dispose();
    _motherAddressController.dispose();
    _motherOccupationController.dispose();
    _motherWorkAddressController.dispose();
    _motherSalaryController.dispose();
    _fatherNameController.dispose();
    _fatherIdController.dispose();
    _fatherAddressController.dispose();
    _fatherOccupationController.dispose();
    _fatherWorkAddressController.dispose();
    _fatherSalaryController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      // Mother
      widget.registrationData.motherName = _motherNameController.text.trim();
      widget.registrationData.motherId = _motherIdController.text.trim();
      widget.registrationData.motherAddress =
          _motherAddressController.text.trim();
      widget.registrationData.motherOccupation =
          _motherOccupationController.text.trim();
      widget.registrationData.motherWorkAddress =
          _motherWorkAddressController.text.trim();
      widget.registrationData.motherSalary =
          _motherSalaryController.text.trim();
      // Father
      widget.registrationData.fatherName = _fatherNameController.text.trim();
      widget.registrationData.fatherId = _fatherIdController.text.trim();
      widget.registrationData.fatherAddress =
          _fatherAddressController.text.trim();
      widget.registrationData.fatherOccupation =
          _fatherOccupationController.text.trim();
      widget.registrationData.fatherWorkAddress =
          _fatherWorkAddressController.text.trim();
      widget.registrationData.fatherSalary =
          _fatherSalaryController.text.trim();
      widget.onNext();
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
            const Text(
              "Mother's Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _motherNameController,
              decoration: const InputDecoration(labelText: "Mother's Name"),
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _motherIdController,
              decoration: const InputDecoration(labelText: 'ID Nr.'),
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _motherAddressController,
              decoration: const InputDecoration(labelText: 'Home Address'),
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _motherOccupationController,
              decoration: const InputDecoration(labelText: 'Occupation'),
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _motherWorkAddressController,
              decoration: const InputDecoration(labelText: 'Work Address'),
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _motherSalaryController,
              decoration: const InputDecoration(labelText: 'Monthly Salary'),
              keyboardType: TextInputType.number,
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            const Text(
              "Father's Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fatherNameController,
              decoration: const InputDecoration(labelText: "Father's Name"),
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fatherIdController,
              decoration: const InputDecoration(labelText: 'ID Nr.'),
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fatherAddressController,
              decoration: const InputDecoration(labelText: 'Home Address'),
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fatherOccupationController,
              decoration: const InputDecoration(labelText: 'Occupation'),
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fatherWorkAddressController,
              decoration: const InputDecoration(labelText: 'Work Address'),
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fatherSalaryController,
              decoration: const InputDecoration(labelText: 'Monthly Salary'),
              keyboardType: TextInputType.number,
              validator:
                  (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: widget.onBack,
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: _handleNext,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
