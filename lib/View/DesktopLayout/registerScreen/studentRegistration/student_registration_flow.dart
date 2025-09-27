import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Model/student_registration_data.dart';
import 'registration_step1.dart';
import 'registration_step2.dart';
import 'registration_step3.dart';
import 'registration_step4.dart';

class StudentRegistrationFlow extends StatefulWidget {
  final String initialUsername;
  final String initialEmail;
  final String initialPassword;
  const StudentRegistrationFlow({
    super.key,
    required this.initialUsername,
    required this.initialEmail,
    required this.initialPassword,
  });

  @override
  State<StudentRegistrationFlow> createState() =>
      _StudentRegistrationFlowState();
}

class _StudentRegistrationFlowState extends State<StudentRegistrationFlow> {
  int _currentStep = 0;
  final StudentRegistrationData _registrationData = StudentRegistrationData();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _registrationData.username = widget.initialUsername;
    _registrationData.email = widget.initialEmail;
    _registrationData.password = widget.initialPassword;
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
  }

  Future<void> _submitRegistration() async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .add(_registrationData.toMap());
      setState(() {
        _isSubmitting = false;
      });
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Registration completed successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _currentStep = 0;
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to register: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return StudentRegistrationStep1(
          registrationData: _registrationData,
          onNext: _nextStep,
        );
      case 1:
        return StudentRegistrationStep2(
          registrationData: _registrationData,
          onNext: _nextStep,
          onBack: _prevStep,
        );
      case 2:
        return StudentRegistrationStep3(
          registrationData: _registrationData,
          onNext: _nextStep,
          onBack: _prevStep,
        );
      case 3:
        return StudentRegistrationStep4(
          registrationData: _registrationData,
          onSubmit: _submitRegistration,
          onBack: _prevStep,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        // Remove height: double.infinity to allow Center to work vertically
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8C5FF5), Color.fromARGB(255, 156, 129, 219)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              constraints: const BoxConstraints(maxWidth: 700),
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(141, 233, 233, 233),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 7,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min, // Only as tall as needed
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Color(0xFF8C5FF5),
                          ),
                          label: Text(
                            'Back to Login',
                            style: TextStyle(color: Color(0xFF8C5FF5)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _currentStep == index
                                        ? Colors.blue
                                        : Colors.grey[300],
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        height:
                            520, // You can adjust this or remove for dynamic height
                        child: _buildStep(),
                      ),
                    ],
                  ),
                  if (_isSubmitting)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
