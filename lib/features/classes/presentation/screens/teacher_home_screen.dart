import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../auth/logic/auth_state.dart';
import '../../../auth/presentation/screens/role_selection_screen.dart';
import '../../logic/classes_cubit.dart';
 import '../../../attendance/presentation/screens/start_attendance_screen.dart'; // الاستدعاء الجديد

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  String tId = '';
  String tName = '';

  @override
  void initState() {
    super.initState();
    _loadTeacherClasses();
  }

  void _loadTeacherClasses() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      tId = authState.user.uid;
      tName = authState.user.name;
      // جلب الكلاسات الخاصة بهذا المدرس من الـ Firestore
      context.read<ClassesCubit>().getTeacherClasses(tId);
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
              'Teacher Dashboard',
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
            if (state is ClassCreatedSuccess) {
              // إعادة تحميل القائمة فور إنشاء مادة جديدة
              _loadTeacherClasses();
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
                      // الإضافة هنا: الانتقال لشاشة الحضور عند الضغط على الكارت
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StartAttendanceScreen(classData: classModel),
                          ),
                        );
                      },
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
                          Chip(
                            label: Text('Code: ${classModel.joinCode}'),
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
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
            _showCreateClassDialog(context);
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Create Class', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              Icons.school_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.4)
          ),
          const SizedBox(height: 16),
          const Text(
            'You haven\'t created any classes yet.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Click the button below to create one.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showCreateClassDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create New Class', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Class Name',
                  hintText: 'e.g. Flutter Development',
                  prefixIcon: const Icon(Icons.class_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val!.isEmpty ? 'Please enter class name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g. 4th Year - CS Dept',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val!.isEmpty ? 'Please enter description' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<ClassesCubit>().createNewClass(
                  name: nameController.text,
                  description: descController.text,
                  teacherId: tId,
                  teacherName: tName,
                );

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Class created successfully!'), backgroundColor: AppColors.secondary),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}