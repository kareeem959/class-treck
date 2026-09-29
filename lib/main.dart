import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Repositories
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/classes/data/repositories/classes_repository.dart';
import 'features/attendance/data/repositories/attendance_repository.dart';

// Cubits
import 'features/auth/logic/auth_cubit.dart';
import 'features/classes/logic/classes_cubit.dart';
import 'features/attendance/logic/attendance_cubit.dart';

// Screens
import 'features/auth/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ClassTrackApp());
}

class ClassTrackApp extends StatelessWidget {
  const ClassTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Inject AuthCubit and check user status immediately
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(AuthRepository())..checkAuthStatus(),
        ),
        // Inject ClassesCubit
        BlocProvider<ClassesCubit>(
          create: (context) => ClassesCubit(ClassesRepository()),
        ),
        // Inject AttendanceCubit
        BlocProvider<AttendanceCubit>(
          create: (context) => AttendanceCubit(AttendanceRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'ClassTrack',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          fontFamily: 'Cairo',
        ),
        home: const SplashScreen(),
      ),
    );
  }
}