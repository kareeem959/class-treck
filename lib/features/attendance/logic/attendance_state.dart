import '../data/models/attendance_record_model.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class SessionStartedSuccess extends AttendanceState {
  final String sessionId;
  SessionStartedSuccess(this.sessionId);
}

class PunchInSuccess extends AttendanceState {
  final AttendanceRecordModel record;
  PunchInSuccess(this.record);
}

class AttendanceError extends AttendanceState {
  final String message;
  AttendanceError(this.message);
}