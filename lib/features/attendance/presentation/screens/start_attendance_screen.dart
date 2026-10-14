import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
 import '../../../classes/data/models/class_model.dart';
import '../../logic/attendance_cubit.dart';
import '../../logic/attendance_state.dart';
import '../../data/models/attendance_session_model.dart';
import 'teacher_active_session_screen.dart';

class StartAttendanceScreen extends StatefulWidget {
  final ClassModel classData;

  const StartAttendanceScreen({super.key, required this.classData});

  @override
  State<StartAttendanceScreen> createState() => _StartAttendanceScreenState();
}

class _StartAttendanceScreenState extends State<StartAttendanceScreen> {
  AttendanceMode _selectedMode = AttendanceMode.location;
  double _radius = 50.0;
  final TextEditingController _formUrlController = TextEditingController(); // كنترولر للينك

  @override
  void dispose() {
    _formUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Start Attendance', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocConsumer<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is SessionStartedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Session Started Successfully!'), backgroundColor: Colors.green),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TeacherActiveSessionScreen(
                  sessionId: state.sessionId,
                  classData: widget.classData,
                  radius: _radius,
                ),
              ),
            );
          } else if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Class Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.school, color: Colors.blue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.classData.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(widget.classData.description, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Select Mode
                  const Text('Select Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildModeOption(
                    title: 'Location Punch-In',
                    subtitle: 'Simple attendance with location verification',
                    icon: Icons.location_on,
                    mode: AttendanceMode.location,
                  ),
                  const SizedBox(height: 12),
                  _buildModeOption(
                    title: 'Location-Restricted Quiz',
                    subtitle: 'Location verification + Google Form quiz',
                    icon: Icons.quiz,
                    mode: AttendanceMode.quiz,
                  ),

                  // إظهار حقل إدخال لينك جوجل فورم لو اختار Quiz
                  if (_selectedMode == AttendanceMode.quiz) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _formUrlController,
                      decoration: InputDecoration(
                        labelText: 'Google Form URL',
                        hintText: 'https://forms.gle/...',
                        prefixIcon: const Icon(Icons.link, color: Colors.blue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // 3. Allowed Radius Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Allowed Radius (meters)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('${_radius.toInt()} m', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: Colors.blue.shade100,
                      thumbColor: Colors.blue,
                      valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                    ),
                    child: Slider(
                      value: _radius,
                      min: 10,
                      max: 200,
                      divisions: 19,
                      label: '${_radius.toInt()} m',
                      onChanged: (value) {
                        setState(() {
                          _radius = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 4. Start Session Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: state is AttendanceLoading
                          ? null
                          : () {
                        if (_selectedMode == AttendanceMode.quiz && _formUrlController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a Google Form URL'), backgroundColor: Colors.orange),
                          );
                          return;
                        }
                        context.read<AttendanceCubit>().startSession(
                          classId: widget.classData.id,
                          teacherId: widget.classData.teacherId,
                          mode: _selectedMode,
                          radius: _radius,
                          googleFormUrl: _selectedMode == AttendanceMode.quiz ? _formUrlController.text.trim() : null,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: state is AttendanceLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Start Session', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeOption({required String title, required String subtitle, required IconData icon, required AttendanceMode mode}) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.blue : Colors.black)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}