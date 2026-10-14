import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String classId;
  final String teacherId;
  final DateTime startTime;
  final DateTime expiresAt;
  final double latitude;
  final double longitude;
  final double allowedRadius; // النطاق المسموح بالمتر (مثلاً 50 متر)
  final bool isActive;

  SessionModel({
    required this.id,
    required this.classId,
    required this.teacherId,
    required this.startTime,
    required this.expiresAt,
    required this.latitude,
    required this.longitude,
    required this.allowedRadius,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'teacherId': teacherId,
      'startTime': Timestamp.fromDate(startTime),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'latitude': latitude,
      'longitude': longitude,
      'allowedRadius': allowedRadius,
      'isActive': isActive,
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map, String docId) {
    return SessionModel(
      id: docId,
      classId: map['classId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      allowedRadius: (map['allowedRadius'] ?? 50.0).toDouble(),
      isActive: map['isActive'] ?? true,
    );
  }
}