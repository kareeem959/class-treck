class ClassModel {
  final String id;
  final String name;
  final String description;
  final String teacherId;
  final String teacherName;
  final String joinCode;

  ClassModel({
    required this.id,
    required this.name,
    required this.description,
    required this.teacherId,
    required this.teacherName,
    required this.joinCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'joinCode': joinCode,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory ClassModel.fromMap(Map<String, dynamic> map, String docId) {
    return ClassModel(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      joinCode: map['joinCode'] ?? '',
    );
  }
}