import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';

class ClassesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a random 6-character code (e.g., A7K3F9)
  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ));
  }

  // Teacher creates a new class
  Future<ClassModel> createClass({
    required String name,
    required String description,
    required String teacherId,
    required String teacherName,
  }) async {
    final joinCode = _generateJoinCode();
    final docRef = _firestore.collection('classes').doc();

    final newClass = ClassModel(
      id: docRef.id,
      name: name,
      description: description,
      teacherId: teacherId,
      teacherName: teacherName,
      joinCode: joinCode,
    );

    await docRef.set(newClass.toMap());
    return newClass;
  }

  // Teacher gets their created classes
  Future<List<ClassModel>> getTeacherClasses(String teacherId) async {
    final snapshot = await _firestore
        .collection('classes')
        .where('teacherId', isEqualTo: teacherId)
        .get();

    return snapshot.docs
        .map((doc) => ClassModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Student joins a class using a code
  Future<void> joinClass(String joinCode, String studentId) async {
    // 1. Find the class by join code
    final query = await _firestore
        .collection('classes')
        .where('joinCode', isEqualTo: joinCode.trim().toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid join code. Class not found.');
    }

    final classId = query.docs.first.id;

    // 2. Check if already enrolled
    final enrollmentId = '${classId}_$studentId';
    final enrollmentDoc = await _firestore.collection('enrollments').doc(enrollmentId).get();

    if (enrollmentDoc.exists) {
      throw Exception('You are already enrolled in this class.');
    }

    // 3. Save enrollment
    await _firestore.collection('enrollments').doc(enrollmentId).set({
      'classId': classId,
      'studentId': studentId,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  // Student gets their enrolled classes
  Future<List<ClassModel>> getStudentClasses(String studentId) async {
    final enrollmentsSnapshot = await _firestore
        .collection('enrollments')
        .where('studentId', isEqualTo: studentId)
        .get();

    if (enrollmentsSnapshot.docs.isEmpty) {
      return [];
    }

    List<ClassModel> studentClasses = [];

    for (var doc in enrollmentsSnapshot.docs) {
      final classId = doc['classId'];
      final classDoc = await _firestore.collection('classes').doc(classId).get();

      if (classDoc.exists) {
        studentClasses.add(ClassModel.fromMap(classDoc.data()!, classDoc.id));
      }
    }

    return studentClasses;
  }
}