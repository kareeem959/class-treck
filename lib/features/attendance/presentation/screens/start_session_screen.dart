import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../auth/logic/auth_state.dart';
import '../../data/models/attendance_session_model.dart';
import '../../logic/attendance_cubit.dart';
import '../../logic/attendance_state.dart';
import 'live_attendance_screen.dart';

class StartSessionScreen extends StatefulWidget {
  final String classId;
  const StartSessionScreen({super.key, required this.classId});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  double _radius = AppConstants.defaultRadiusMeters;
  AttendanceMode _mode = AttendanceMode.punchIn;
  final _formUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthCubit>().state as Authenticated).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Attendance', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is SessionStartedSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LiveAttendanceScreen(sessionId: state.sessionId),
              ),
            );
          } else if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                RadioListTile<AttendanceMode>(
                  title: const Text('Location Punch-In'),
                  subtitle: const Text('Simple attendance with location verification'),
                  value: AttendanceMode.punchIn,
                  groupValue: _mode,
                  onChanged: (val) => setState(() => _mode = val!),
                  activeColor: AppColors.primary,
                ),
                RadioListTile<AttendanceMode>(
                  title: const Text('Location-Restricted Quiz'),
                  subtitle: const Text('Location verification + Google Form quiz'),
                  value: AttendanceMode.quiz,
                  groupValue: _mode,
                  onChanged: (val) => setState(() => _mode = val!),
                  activeColor: AppColors.primary,
                ),
                if (_mode == AttendanceMode.quiz) ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _formUrlController,
                    label: 'Google Form URL',
                    hint: 'Paste the Google Form link here',
                    prefixIcon: Icons.link,
                  ),
                ],
                const SizedBox(height: 32),
                const Text('Allowed Radius (meters)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _radius,
                        min: 10,
                        max: 200,
                        divisions: 19,
                        label: '${_radius.toInt()} m',
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _radius = val),
                      ),
                    ),
                    Text('${_radius.toInt()} m', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: 'Start Session',
                  isLoading: state is AttendanceLoading,
                  onPressed: () {
                    if (_mode == AttendanceMode.quiz && _formUrlController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the Google Form URL'), backgroundColor: AppColors.error));
                      return;
                    }
                    context.read<AttendanceCubit>().startSession(
                      classId: widget.classId,
                      teacherId: user.uid,
                      mode: _mode,
                      radius: _radius,
                      googleFormUrl: _mode == AttendanceMode.quiz ? _formUrlController.text : null,
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