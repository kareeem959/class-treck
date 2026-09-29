import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../logic/auth_cubit.dart';
import '../../logic/auth_state.dart';
import 'package:class_track/features/classes/presentation/screens/student_home_screen.dart';
 class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentCodeController = TextEditingController();
  final _departmentController = TextEditingController();

  String? _selectedYear;
  final List<String> _academicYears = [
    'First Year',
    'Second Year',
    'Third Year',
    'Fourth Year'
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Sign Up', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error)
            );
          } else if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account created successfully!'), backgroundColor: AppColors.secondary)
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
                  (route) => false,
            );
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
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    validator: (val) => val!.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val!.isEmpty ? 'Please enter your email' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Create a password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (val) => val!.length < 6 ? 'Password must be at least 6 chars' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _studentCodeController,
                    label: 'Student Code',

                    prefixIcon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Please enter your student code' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Academic Year', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedYear,
                    hint: const Text('Select Year'),
                    items: _academicYears.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
                    onChanged: (val) => setState(() => _selectedYear = val),
                    validator: (val) => val == null ? 'Please select your academic year' : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _departmentController,
                    label: 'Department',
                    hint: 'e.g. Software Engineering',
                    prefixIcon: Icons.computer_outlined,
                    validator: (val) => val!.isEmpty ? 'Please enter your department' : null,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Sign Up',
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _selectedYear != null) {
                        context.read<AuthCubit>().registerStudent(
                          name: _nameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                          studentCode: _studentCodeController.text,
                          academicYear: _selectedYear!,
                          department: _departmentController.text,
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