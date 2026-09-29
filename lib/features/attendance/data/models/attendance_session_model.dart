enum AttendanceMode { punchIn, quiz }

class AttendanceSessionModel {
  final String id;
  final String classId;
  final String teacherId;
  final AttendanceMode mode;
  final double latitude;
  final double longitude;
  final double radius;
  final DateTime startTime;
  final DateTime expiryTime;
  final String status;
  final String? googleFormUrl;

  AttendanceSessionModel({
    required this.id,
    required this.classId,
    required this.teacherId,
    required this.mode,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.startTime,
    required this.expiryTime,
    required this.status,
    this.googleFormUrl,
  });

  factory AttendanceSessionModel.fromMap(Map<String, dynamic> map, String docId) {
    return AttendanceSessionModel(
      id: docId,
      classId: map['classId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      mode: map['mode'] == 'quiz' ? AttendanceMode.quiz : AttendanceMode.punchIn,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      radius: (map['radius'] as num).toDouble(),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      expiryTime: DateTime.fromMillisecondsSinceEpoch(map['expiryTime']),
      status: map['status'] ?? 'active',
      googleFormUrl: map['googleFormUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'teacherId': teacherId,
      'mode': mode == AttendanceMode.quiz ? 'quiz' : 'punch_in',
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'startTime': startTime.millisecondsSinceEpoch,
      'expiryTime': expiryTime.millisecondsSinceEpoch,
      'status': status,
      if (googleFormUrl != null) 'googleFormUrl': googleFormUrl,
    };
  }
}