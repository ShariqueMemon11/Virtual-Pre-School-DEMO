class StudentRegistrationData {
  // Child Info
  String? childName;
  String? age;
  DateTime? dateOfBirth;
  String? homePhone;
  String? email;
  String? motherCell;
  String? fatherCell;

  // Registration Info
  String? username;
  String? password;

  // Mother Info
  String? motherName;
  String? motherId;
  String? motherAddress;
  String? motherOccupation;
  String? motherWorkAddress;
  String? motherSalary;

  // Father Info
  String? fatherName;
  String? fatherId;
  String? fatherAddress;
  String? fatherOccupation;
  String? fatherWorkAddress;
  String? fatherSalary;

  // Other Family Members (up to 3)
  List<String?> otherFamilyMembers = List.filled(3, null);

  // Special Equipment, Allergies, Behavioral/Mental Health Issues
  String? specialEquipment;
  String? allergies;
  String? behavioralIssues;

  // Policy Acceptance
  bool policyAccepted = false;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'childName': childName,
      'age': age,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'homePhone': homePhone,
      'email': email,
      'motherCell': motherCell,
      'fatherCell': fatherCell,
      'username': username,
      'password': password,
      'motherName': motherName,
      'motherId': motherId,
      'motherAddress': motherAddress,
      'motherOccupation': motherOccupation,
      'motherWorkAddress': motherWorkAddress,
      'motherSalary': motherSalary,
      'fatherName': fatherName,
      'fatherId': fatherId,
      'fatherAddress': fatherAddress,
      'fatherOccupation': fatherOccupation,
      'fatherWorkAddress': fatherWorkAddress,
      'fatherSalary': fatherSalary,
      'otherFamilyMembers': otherFamilyMembers,
      'specialEquipment': specialEquipment,
      'allergies': allergies,
      'behavioralIssues': behavioralIssues,
      'policyAccepted': policyAccepted,
    };
  }
} 