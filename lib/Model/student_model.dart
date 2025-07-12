class Student {
  final String name;
  final String phone;
  final String address;
  final String email;

  Student({
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
