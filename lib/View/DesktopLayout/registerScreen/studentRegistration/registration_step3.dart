import 'package:flutter/material.dart';
import '../../../../Model/student_registration_data.dart';

class StudentRegistrationStep3 extends StatefulWidget {
  final StudentRegistrationData registrationData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StudentRegistrationStep3({
    super.key,
    required this.registrationData,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<StudentRegistrationStep3> createState() =>
      _StudentRegistrationStep3State();
}

class _StudentRegistrationStep3State extends State<StudentRegistrationStep3> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _familyControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final _specialEquipmentController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _behavioralController = TextEditingController();

  @override
  void dispose() {
    for (final c in _familyControllers) {
      c.dispose();
    }
    _specialEquipmentController.dispose();
    _allergiesController.dispose();
    _behavioralController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      for (int i = 0; i < 3; i++) {
        widget.registrationData.otherFamilyMembers[i] =
            _familyControllers[i].text.trim().isEmpty
                ? null
                : _familyControllers[i].text.trim();
      }
      widget.registrationData.specialEquipment =
          _specialEquipmentController.text.trim();
      widget.registrationData.allergies = _allergiesController.text.trim();
      widget.registrationData.behavioralIssues =
          _behavioralController.text.trim();
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
              'List other family members attending',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < 3; i++) ...[
              TextFormField(
                controller: _familyControllers[i],
                decoration: InputDecoration(labelText: '${i + 1}.'),
                validator: (value) => null, // Optional
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialEquipmentController,
              decoration: const InputDecoration(
                labelText: 'Special equipment',
                helperText:
                    'Please list any orthodontic devices/prosthesis, glasses etc.',
              ),
              validator: (value) => null, // Optional
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _allergiesController,
              decoration: const InputDecoration(
                labelText: 'Allergies',
                helperText:
                    'Please list any allergies or reactions to any food, animals, pediatric asthma etc. It’s very important to mention nut allergies.',
              ),
              validator: (value) => null, // Optional
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _behavioralController,
              decoration: const InputDecoration(
                labelText: 'Behavioral/Mental Health Issues',
                helperText:
                    'Please mention any behavioral conditions or mental health diagnoses e.g. Autism, ADHD etc.',
              ),
              validator: (value) => null, // Optional
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
