enum UserRole { teacher, student }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  final String? studentCode;
  final String? academicYear;
  final String? department;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.studentCode,
    this.academicYear,
    this.department,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: (map['role'] == 'teacher') ? UserRole.teacher : UserRole.student,
      studentCode: map['studentCode'],
      academicYear: map['academicYear'],
      department: map['department'],
    );
  }

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'role': role == UserRole.teacher ? 'teacher' : 'student',
    };

    if (role == UserRole.student) {
      data['studentCode'] = studentCode;
      data['academicYear'] = academicYear;
      data['department'] = department;
    }
    return data;
  }
}