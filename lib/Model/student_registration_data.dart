class StudentRegistrationData {
  String? childName;
  String? age;
  DateTime? dateOfBirth;
  String? homePhone;
  String? email;
  String? motherCell;
  String? fatherCell;

  String? motherName;
  String? motherId;
  String? motherOccupation;

  String? fatherName;
  String? fatherId;
  String? fatherOccupation;

  List<String?> otherFamilyMembers = [];
  String? specialEquipment;
  String? allergies;
  String? behavioralIssues;
  bool? policyAccepted;
  String? password;

  // 📌 Add new fields
  String? motherCnicFile;
  String? fatherCnicFile;
  String? birthCertificateFile;

  Map<String, dynamic> toMap() {
    return {
      'childName': childName,
      'age': age,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'homePhone': homePhone,
      'email': email,
      'motherCell': motherCell,
      'fatherCell': fatherCell,
      'motherName': motherName,
      'motherId': motherId,
      'motherOccupation': motherOccupation,
      'fatherName': fatherName,
      'fatherId': fatherId,
      'fatherOccupation': fatherOccupation,
      'otherFamilyMembers': otherFamilyMembers,
      'specialEquipment': specialEquipment,
      'allergies': allergies,
      'behavioralIssues': behavioralIssues,
      'policyAccepted': policyAccepted,

      'motherCnicFile': motherCnicFile,
      'fatherCnicFile': fatherCnicFile,
      'birthCertificateFile': birthCertificateFile,
    };
  }
}
