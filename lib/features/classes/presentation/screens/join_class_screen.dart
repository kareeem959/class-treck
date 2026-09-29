import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../auth/logic/auth_state.dart';
import '../../logic/classes_cubit.dart';
import '../../logic/classes_state.dart' hide ClassesError, ClassesState, ClassesLoading;

class JoinClassScreen extends StatefulWidget {
  const JoinClassScreen({super.key});

  @override
  State<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends State<JoinClassScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthCubit>().state as Authenticated).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join New Class', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<ClassesCubit, ClassesState>(
        listener: (context, state) {
          if (state is ClassOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.secondary));
            Navigator.pop(context); // Go back after success
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
                  const Text(
                    'Enter the class join code provided by your teacher.',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _codeController,
                    label: 'Join Code',
                    hint: 'e.g. A7K3F9',
                    prefixIcon: Icons.lock_outline,
                    validator: (val) => val!.isEmpty ? 'Please enter a code' : null,
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: 'Join Class',
                    isLoading: state is ClassesLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ClassesCubit>().joinClass(
                          _codeController.text,
                          user.uid,
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