import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../auth/logic/auth_state.dart';
import '../../logic/classes_cubit.dart';
import '../../logic/classes_state.dart' hide ClassesState, ClassesError, ClassesLoading;

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthCubit>().state as Authenticated).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Class', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<ClassesCubit, ClassesState>(
        listener: (context, state) {
          if (state is ClassOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.secondary));
            Navigator.pop(context); // Go back to home after success
          } else if (state is ClassesError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _nameController,
                    label: 'Class Name',
                    hint: 'e.g. Mobile Programming',
                    validator: (val) => val!.isEmpty ? 'Required field' : null,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _descController,
                    label: 'Description (Optional)',
                    hint: 'e.g. Level 2 - Section A',
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: 'Create Class',
                    isLoading: state is ClassesLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ClassesCubit>().createNewClass(
                          name: _nameController.text,
                          description: _descController.text,
                          teacherId: user.uid,
                          teacherName: 'Dr. ${user.name}',
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}