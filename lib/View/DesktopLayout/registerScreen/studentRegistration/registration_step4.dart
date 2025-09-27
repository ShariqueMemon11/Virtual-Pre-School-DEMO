import 'package:flutter/material.dart';
import '../../../../Model/student_registration_data.dart';

class StudentRegistrationStep4 extends StatefulWidget {
  final StudentRegistrationData registrationData;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const StudentRegistrationStep4({
    super.key,
    required this.registrationData,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  State<StudentRegistrationStep4> createState() =>
      _StudentRegistrationStep4State();
}

class _StudentRegistrationStep4State extends State<StudentRegistrationStep4> {
  bool _policyAccepted = false;

  void _handleSubmit() {
    if (_policyAccepted) {
      widget.registrationData.policyAccepted = true;
      widget.onSubmit();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept the policies to continue.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: _policyAccepted,
            onChanged: (val) {
              setState(() {
                _policyAccepted = val ?? false;
              });
            },
            title: const Text(
              'I accept all the policies and grant permission for my child to participate in all school activities, which form part of the daily routine. I also grant permission for my child to use all play equipment and participate in all activities of the school, and to leave the school premises under the supervision of a staff member for scheduled field trips.',
              style: TextStyle(fontSize: 15),
            ),
            controlAffinity: ListTileControlAffinity.leading,
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
                onPressed: _handleSubmit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
