import '../data/models/class_model.dart';

abstract class ClassesState {}

class ClassesInitial extends ClassesState {}

class ClassesLoading extends ClassesState {}

class ClassesLoaded extends ClassesState {
  final List<ClassModel> classes;
  ClassesLoaded(this.classes);
}

class ClassOperationSuccess extends ClassesState {
  final String message;
  ClassOperationSuccess(this.message);
}

class ClassesError extends ClassesState {
  final String message;
  ClassesError(this.message);
}