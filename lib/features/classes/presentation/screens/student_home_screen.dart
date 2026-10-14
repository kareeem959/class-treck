import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../auth/logic/auth_state.dart';
import '../../../auth/presentation/screens/role_selection_screen.dart';
import '../../logic/classes_cubit.dart';
import '../../data/models/class_model.dart';
import '../../../attendance/data/models/attendance_session_model.dart';
import '../../../attendance/presentation/screens/student_active_session_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String studentId = '';
  String studentName = '';

  @override
  void initState() {
    super.initState();
    _loadStudentClasses();
  }

  void _loadStudentClasses() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      studentId = authState.user.uid;
      studentName = authState.user.name;
      context.read<ClassesCubit>().getStudentClasses(studentId);
    }
  }

  // دالة للتحقق من وجود سشن شغال قبل فتح الشاشة
  Future<void> _checkForActiveSession(BuildContext context, ClassModel classModel) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final query = await FirebaseFirestore.instance
          .collection('attendance_sessions')
          .where('classId', isEqualTo: classModel.id)
          .where('status', isEqualTo: 'active')
          .get();

      if (!context.mounted) return;
      Navigator.pop(context); // إغلاق مؤشر التحميل

      if (query.docs.isNotEmpty) {
        // لو لقينا سشن، نتأكد إن وقته لسه مخلصش
        final sessionData = query.docs.first.data();
        final session = AttendanceSessionModel.fromMap(sessionData, query.docs.first.id);

        if (DateTime.now().isBefore(session.expiryTime)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentActiveSessionScreen(
                classData: classModel,
                session: session,
                studentId: studentId,
                studentName: studentName,
                studentCode: studentId, // مؤقتاً بنبعت الـ ID ككود لحد ما نضيف خانة الكود في التسجيل
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The active session has expired.'), backgroundColor: Colors.orange),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active session for this class right now.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
              'My Classes',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 24)
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.error),
              onPressed: () {
                context.read<AuthCubit>().logout();
              },
            ),
          ],
        ),
        body: BlocConsumer<ClassesCubit, ClassesState>(
          listener: (context, state) {
            if (state is ClassJoinedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Successfully joined the class!'), backgroundColor: AppColors.secondary),
              );
              _loadStudentClasses();
            } else if (state is ClassesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            }
          },
          builder: (context, state) {
            if (state is ClassesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ClassesLoaded) {
              final classes = state.classes;
              if (classes.isEmpty) {
                return _buildEmptyView();
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final classModel = classes[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      // التعديل هنا: استدعاء دالة التحقق عند الضغط
                      onTap: () => _checkForActiveSession(context, classModel),
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        classModel.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(classModel.description),
                          const SizedBox(height: 8),
                          Text(
                            'Teacher: ${classModel.teacherName}',
                            style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return _buildEmptyView();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showJoinClassDialog(context);
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Join Class', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              Icons.class_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.4)
          ),
          const SizedBox(height: 16),
          const Text(
            'You haven\'t joined any classes yet.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Click the button below to join one.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showJoinClassDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Join a Class', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: codeController,
          decoration: InputDecoration(
            hintText: 'Enter Class Code',
            prefixIcon: const Icon(Icons.pin_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.isNotEmpty) {
                context.read<ClassesCubit>().joinClass(
                  codeController.text.trim(),
                  studentId,
                );
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Join', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}