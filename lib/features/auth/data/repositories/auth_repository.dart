import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> registerStudent({
    required String name,
    required String email,
    required String password,
    required String studentCode,
    required String academicYear,
    required String department,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final userName = name.trim().isEmpty ? 'Name' : name.trim();

    final user = UserModel(
      uid: credential.user!.uid,
      name: userName,
      email: email.trim(),
      role: UserRole.student,
      studentCode: studentCode.trim(),
      academicYear: academicYear,
      department: department,
    );

    await _firestore.collection('users').doc(user.uid).set(user.toMap()); //[cite: 6]
    return user;
  }

  Future<UserModel> registerTeacher({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      name: name.trim(),
      email: email.trim(),
      role: UserRole.teacher,
    );

    await _firestore.collection('users').doc(user.uid).set(user.toMap()); //[cite: 6]
    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
    if (!doc.exists) {
      throw Exception("User data does not exist in the database.");
    }

    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}