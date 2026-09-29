import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../auth/logic/auth_state.dart';
import '../../data/models/attendance_session_model.dart';
import '../../logic/attendance_cubit.dart';
import '../../logic/attendance_state.dart';
import '../widgets/countdown_timer_widget.dart';
import 'punch_success_screen.dart';
import 'google_form_quiz_screen.dart';

class StudentSessionScreen extends StatelessWidget {
  final AttendanceSessionModel session;

  const StudentSessionScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthCubit>().state as Authenticated).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Attendance', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is PunchInSuccess) {
            if (session.mode == AttendanceMode.punchIn) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PunchSuccessScreen()),
              );
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => GoogleFormQuizScreen(session: session))
              );
            }
          } else if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error)
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                          session.mode == AttendanceMode.punchIn ? 'Location Punch-In' : 'Location-Restricted Quiz',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                      ),
                      const SizedBox(height: 8),
                      const Text('Time remaining', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      CountdownTimerWidget(
                        expiryTime: session.expiryTime,
                        onExpire: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Session expired!'), backgroundColor: AppColors.error)
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.radar, color: AppColors.primary),
                  title: const Text('Allowed Radius', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${session.radius.toInt()} meters'),
                ),
                const Spacer(),
                CustomButton(
                  text: session.mode == AttendanceMode.punchIn ? 'Punch In' : 'Verify Location & Start Quiz',
                  isLoading: state is AttendanceLoading,
                  onPressed: () {
                    context.read<AttendanceCubit>().punchIn(
                      session: session,
                      studentId: user.uid,
                      studentName: user.name,
                      studentCode: user.studentCode ?? '',
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}