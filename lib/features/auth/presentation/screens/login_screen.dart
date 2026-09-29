import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../classes/presentation/screens/student_home_screen.dart';
import '../../../classes/presentation/screens/teacher_home_screen.dart';
import '../../data/models/user_model.dart';
import '../../logic/auth_cubit.dart';
import '../../logic/auth_state.dart';
import 'student_register_screen.dart';
import 'teacher_register_screen.dart';

class LoginScreen extends StatefulWidget {
  final UserRole role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary)
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
          } else if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login successful!'), backgroundColor: AppColors.secondary));

            // هنا الفحص الحقيقي
            if (state.user.role == UserRole.teacher) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const TeacherHomeScreen()),
                    (route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
                    (route) => false,
              );
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Login to continue as ${widget.role == UserRole.teacher ? "Teacher" : "Student"}', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 40),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val!.isEmpty ? 'Please enter email' : null,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (val) => val!.length < 6 ? 'Password must be at least 6 chars' : null,
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: 'Login',
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthCubit>().login(_emailController.text, _passwordController.text);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary)),
                      TextButton(
                        onPressed: () {
                          if (widget.role == UserRole.student) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentRegisterScreen()));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherRegisterScreen()));
                          }
                        },
                        child: const Text('Sign Up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}