class AttendanceRecordModel {
  final String sessionId;
  final String studentId;
  final String studentName;
  final String studentCode;
  final DateTime timestamp;
  final double distance;
  final String status;
  final bool isQuizSubmitted;

  AttendanceRecordModel({
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.timestamp,
    required this.distance,
    required this.status,
    this.isQuizSubmitted = false,
  });

  factory AttendanceRecordModel.fromMap(Map<String, dynamic> map) {
    return AttendanceRecordModel(
      sessionId: map['sessionId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentCode: map['studentCode'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      distance: (map['distance'] as num).toDouble(),
      status: map['status'] ?? 'rejected',
      isQuizSubmitted: map['isQuizSubmitted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'studentId': studentId,
      'studentName': studentName,
      'studentCode': studentCode,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'distance': distance,
      'status': status,
      'isQuizSubmitted': isQuizSubmitted,
    };
  }
}