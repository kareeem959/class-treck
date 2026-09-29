import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../classes/presentation/screens/student_home_screen.dart';
import '../../../classes/presentation/screens/teacher_home_screen.dart';
import '../../data/models/user_model.dart';
import '../../logic/auth_cubit.dart';
import '../../logic/auth_state.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    // انتظار 3 ثواني لعرض الـ Splash
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // فحص حالة المستخدم بعد انتهاء الوقت
    final authState = context.read<AuthCubit>().state;

    if (authState is Authenticated) {
      if (authState.user.role == UserRole.teacher) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TeacherHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentHomeScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 100, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'ClassTrack',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Smart Attendance for Smarter Learning',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}