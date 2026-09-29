import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/classes_repository.dart';
import '../data/models/class_model.dart';

// --- States ---
abstract class ClassesState {
  final String message;
  const ClassesState({this.message = ''});
}

class ClassesInitial extends ClassesState {}

class ClassesLoading extends ClassesState {}

class ClassCreatedSuccess extends ClassesState {
  final ClassModel newClass;
  ClassCreatedSuccess(this.newClass);
}

class ClassJoinedSuccess extends ClassesState {}

class ClassesLoaded extends ClassesState {
  final List<ClassModel> classes;
  ClassesLoaded(this.classes);
}

class ClassesError extends ClassesState {
  @override
  final String message;
  const ClassesError(this.message) : super(message: message);
}

// --- Cubit ---
class ClassesCubit extends Cubit<ClassesState> {
  final ClassesRepository _repository;

  ClassesCubit(this._repository) : super(ClassesInitial());

  // دعم اسم createClass و createNewClass معاً لمنع أي تضارب
  Future<void> createClass({
    required String name,
    required String description,
    required String teacherId,
    required String teacherName,
  }) async {
    await createNewClass(
      name: name,
      description: description,
      teacherId: teacherId,
      teacherName: teacherName,
    );
  }

  Future<void> createNewClass({
    required String name,
    required String description,
    required String teacherId,
    required String teacherName,
  }) async {
    emit(ClassesLoading());
    try {
      final newClass = await _repository.createClass(
        name: name,
        description: description,
        teacherId: teacherId,
        teacherName: teacherName,
      );
      emit(ClassCreatedSuccess(newClass));
    } catch (e) {
      emit(ClassesError(e.toString()));
    }
  }

  Future<void> joinClass(String joinCode, String studentId) async {
    emit(ClassesLoading());
    try {
      await _repository.joinClass(joinCode, studentId);
      emit(ClassJoinedSuccess());
    } catch (e) {
      emit(ClassesError(e.toString()));
    }
  }

  Future<void> getTeacherClasses(String teacherId) async {
    emit(ClassesLoading());
    try {
      final classes = await _repository.getTeacherClasses(teacherId);
      emit(ClassesLoaded(classes));
    } catch (e) {
      emit(ClassesError(e.toString()));
    }
  }

  Future<void> getStudentClasses(String studentId) async {
    emit(ClassesLoading());
    try {
      final classes = await _repository.getStudentClasses(studentId);
      emit(ClassesLoaded(classes));
    } catch (e) {
      emit(ClassesError(e.toString()));
    }
  }
}