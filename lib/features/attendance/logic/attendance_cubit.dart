import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/attendance_repository.dart';
import '../data/models/attendance_session_model.dart';
import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository _repository;

  AttendanceCubit(this._repository) : super(AttendanceInitial());

  Future<void> startSession({
    required String classId,
    required String teacherId,
    required AttendanceMode mode,
    required double radius,
    String? googleFormUrl,
  }) async {
    emit(AttendanceLoading());
    try {
      final sessionId = await _repository.startSession(
        classId: classId,
        teacherId: teacherId,
        mode: mode,
        radius: radius,
        googleFormUrl: googleFormUrl,
      );
      emit(SessionStartedSuccess(sessionId));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> punchIn({
    required AttendanceSessionModel session,
    required String studentId,
    required String studentName,
    required String studentCode,
  }) async {
    emit(AttendanceLoading());
    try {
      final record = await _repository.punchIn(
        session: session,
        studentId: studentId,
        studentName: studentName,
        studentCode: studentCode,
      );
      emit(PunchInSuccess(record));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }
  Future<void> submitQuiz(String sessionId, String studentId) async {
    emit(AttendanceLoading()); // عشان نظهر مؤشر التحميل
    try {
      await _repository.markQuizSubmitted(sessionId, studentId);
      emit(QuizSubmittedSuccess()); // هنا بنعلن النجاح عشان الشاشة تنقل
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

}