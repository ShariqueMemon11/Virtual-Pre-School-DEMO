class StudentData {
  String? id;
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

  List<String?> otherFamilyMembers;
  String? specialEquipment;
  String? allergies;
  String? behavioralIssues;
  bool? policyAccepted;
  String? password;

  // 📎 Files (Base64 or URLs)
  String? motherCnicFile;
  String? fatherCnicFile;
  String? birthCertificateFile;
  String? childPhotoFile;
  String? assignedClass;
  StudentData({
    this.id,
    this.childName,
    this.age,
    this.dateOfBirth,
    this.homePhone,
    this.email,
    this.motherCell,
    this.fatherCell,
    this.motherName,
    this.motherId,
    this.motherOccupation,
    this.fatherName,
    this.fatherId,
    this.fatherOccupation,
    this.otherFamilyMembers = const [],
    this.specialEquipment,
    this.allergies,
    this.behavioralIssues,
    this.policyAccepted,
    this.password,
    this.motherCnicFile,
    this.fatherCnicFile,
    this.birthCertificateFile,
    this.childPhotoFile,
    this.assignedClass
  });

  /// ✅ Convert model → Firestore Map
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
      'password': password,
      'motherCnicFile': motherCnicFile,
      'fatherCnicFile': fatherCnicFile,
      'birthCertificateFile': birthCertificateFile,
      'childPhotoFile': childPhotoFile,
      'assignedClass':assignedClass
    };
  }

  /// ✅ Convert Firestore Document → Model
  factory StudentData.fromMap(Map<String, dynamic> map) {
    return StudentData(
      childName: map['childName'],
      age: map['age']?.toString(),
      dateOfBirth:
          map['dateOfBirth'] != null
              ? DateTime.tryParse(map['dateOfBirth'])
              : null,
      homePhone: map['homePhone'],
      email: map['email'],
      motherCell: map['motherCell'],
      fatherCell: map['fatherCell'],
      motherName: map['motherName'],
      motherId: map['motherId'],
      motherOccupation: map['motherOccupation'],
      fatherName: map['fatherName'],
      fatherId: map['fatherId'],
      fatherOccupation: map['fatherOccupation'],
      otherFamilyMembers:
          map['otherFamilyMembers'] != null
              ? List<String?>.from(map['otherFamilyMembers'])
              : [],
      specialEquipment: map['specialEquipment'],
      allergies: map['allergies'],
      behavioralIssues: map['behavioralIssues'],
      policyAccepted: map['policyAccepted'] ?? false,
      password: map['password'],
      motherCnicFile: map['motherCnicFile'],
      fatherCnicFile: map['fatherCnicFile'],
      birthCertificateFile: map['birthCertificateFile'],
      childPhotoFile: map['childPhotoFile'],
      assignedClass:map['assignedClass']
    );
  }
}
