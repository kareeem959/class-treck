import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          emit(Authenticated(UserModel.fromMap(doc.data()!, doc.id)));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email: email, password: password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError("Login Failed: make sure the data is correct"));
    }
  }

  Future<void> registerStudent({
    required String name,
    required String email,
    required String password,
    required String studentCode,
    required String academicYear,
    required String department,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.registerStudent(
        name: name,
        email: email,
        password: password,
        studentCode: studentCode,
        academicYear: academicYear,
        department: department,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> registerTeacher({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.registerTeacher(
        name: name,
        email: email,
        password: password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(Unauthenticated());
  }
}