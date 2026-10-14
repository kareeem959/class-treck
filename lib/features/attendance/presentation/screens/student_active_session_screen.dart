import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
 import '../../../classes/data/models/class_model.dart';
import '../../data/models/attendance_session_model.dart';
import '../../logic/attendance_cubit.dart';
import '../../logic/attendance_state.dart';
import 'punch_in_success_screen.dart';
import 'attendance_quiz_screen.dart'; // استدعاء شاشة الكويز الجديدة

class StudentActiveSessionScreen extends StatefulWidget {
  final ClassModel classData;
  final AttendanceSessionModel session;
  final String studentId;
  final String studentName;
  final String studentCode;

  const StudentActiveSessionScreen({
    super.key,
    required this.classData,
    required this.session,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
  });

  @override
  State<StudentActiveSessionScreen> createState() => _StudentActiveSessionScreenState();
}

class _StudentActiveSessionScreenState extends State<StudentActiveSessionScreen> {
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeRemaining();
    });
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    if (widget.session.expiryTime.isAfter(now)) {
      setState(() {
        _timeRemaining = widget.session.expiryTime.difference(now);
      });
    } else {
      setState(() {
        _timeRemaining = Duration.zero;
      });
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpired = _timeRemaining.inSeconds <= 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Active Attendance', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocConsumer<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is PunchInSuccess) {
            // التحقق: هل المود كويز وفيه لينك جوجل فورم متسجل؟
            if (widget.session.mode == AttendanceMode.quiz && widget.session.googleFormUrl != null && widget.session.googleFormUrl!.isNotEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AttendanceQuizScreen(
                    sessionId: widget.session.id,
                    studentId: widget.studentId,
                    className: widget.classData.name,
                    formUrl: widget.session.googleFormUrl!, // نمرر اللينك للشاشة
                  ),
                ),
              );
            } else {
              // لو المود location عادي (أو مفيش لينك فورم)، نروح لشاشة النجاح فوراً
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PunchInSuccessScreen(className: widget.classData.name),
                ),
              );
            }
          } else if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 1. Class & Teacher Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.school, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.classData.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(widget.classData.teacherName, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 2. Punch-In Details Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top Green Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                        ),
                        child: const Center(
                          child: Text(
                            'Location Punch-In',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Timer
                      Text(
                        isExpired ? '00:00' : _formatDuration(_timeRemaining),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: isExpired ? Colors.red : Colors.green,
                        ),
                      ),
                      Text(
                        isExpired ? 'Session Expired' : 'Time remaining',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),

                      // Session Details List
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildDetailRow(Icons.radar, 'Allowed Radius', '${widget.session.radius.toInt()} meters'),
                            const SizedBox(height: 16),
                            _buildDetailRow(Icons.access_time, 'Started At', _formatTime(widget.session.startTime)),
                            const SizedBox(height: 16),
                            _buildDetailRow(Icons.timer_off_outlined, 'Expires At', _formatTime(widget.session.expiryTime)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // 3. Warning Text
                Text(
                  'Make sure you are inside the classroom area\nand location access is enabled.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 16),

                // 4. Punch In Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (isExpired || state is AttendanceLoading)
                        ? null
                        : () {
                      context.read<AttendanceCubit>().punchIn(
                        session: widget.session,
                        studentId: widget.studentId,
                        studentName: widget.studentName,
                        studentCode: widget.studentCode,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: state is AttendanceLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Punch In', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 20),
        const SizedBox(width: 12),
        Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}