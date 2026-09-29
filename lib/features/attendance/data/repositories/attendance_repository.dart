import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/location_service.dart';
import '../models/attendance_session_model.dart';
import '../models/attendance_record_model.dart';

class AttendanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Teacher starts a session
  Future<String> startSession({
    required String classId,
    required String teacherId,
    required AttendanceMode mode,
    required double radius,
    String? googleFormUrl,
  }) async {
    final position = await LocationService.getCurrentLocation();

    final startTime = DateTime.now();
    final expiryTime = startTime.add(const Duration(minutes: 2));

    final docRef = _firestore.collection('attendance_sessions').doc();

    final session = AttendanceSessionModel(
      id: docRef.id,
      classId: classId,
      teacherId: teacherId,
      mode: mode,
      latitude: position.latitude,
      longitude: position.longitude,
      radius: radius,
      startTime: startTime,
      expiryTime: expiryTime,
      status: 'active',
      googleFormUrl: googleFormUrl,
    );

    await docRef.set(session.toMap());
    return docRef.id;
  }

  // Student punches in
  Future<AttendanceRecordModel> punchIn({
    required AttendanceSessionModel session,
    required String studentId,
    required String studentName,
    required String studentCode,
  }) async {
    // 1. Check time
    if (DateTime.now().isAfter(session.expiryTime)) {
      throw Exception('Session has expired.');
    }

    // 2. Check if already attended
    final recordId = '${session.id}_$studentId';
    final existingDoc = await _firestore.collection('attendance_records').doc(recordId).get();

    if (existingDoc.exists) {
      throw Exception('You have already submitted your attendance.');
    }

    // 3. Get student location & calculate distance
    final studentPos = await LocationService.getCurrentLocation();
    final distance = LocationService.calculateDistance(
      startLatitude: session.latitude,
      startLongitude: session.longitude,
      endLatitude: studentPos.latitude,
      endLongitude: studentPos.longitude,
    );

    // 4. Validate distance
    final isWithinRadius = distance <= session.radius;
    final status = isWithinRadius ? 'present' : 'rejected';

    // 5. Save record
    final record = AttendanceRecordModel(
      sessionId: session.id,
      studentId: studentId,
      studentName: studentName,
      studentCode: studentCode,
      timestamp: DateTime.now(),
      distance: distance,
      status: status,
    );

    await _firestore.collection('attendance_records').doc(recordId).set(record.toMap());

    if (!isWithinRadius) {
      throw Exception('Rejected: You are outside the classroom area (Distance: ${distance.toStringAsFixed(1)}m).');
    }

    return record;
  }

  // Mark quiz as submitted
  Future<void> markQuizSubmitted(String sessionId, String studentId) async {
    final recordId = '${sessionId}_$studentId';
    await _firestore.collection('attendance_records').doc(recordId).update({
      'isQuizSubmitted': true,
    });
  }

}