import 'package:equatable/equatable.dart';
import 'package:ellena/core/models/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();
  
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

// Add TaskDetailLoading state
class TaskDetailLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  final TaskType? filterType;
  
  const TasksLoaded({
    required this.tasks,
    this.filterType,
  });
  
  @override
  List<Object?> get props => [tasks, filterType];
}

class TaskDetailLoaded extends TaskState {
  final Task task;
  final List<Task> relatedTasks;
  
  const TaskDetailLoaded({
    required this.task,
    required this.relatedTasks,
  });
  
  @override
  List<Object?> get props => [task, relatedTasks];
}

class TaskError extends TaskState {
  final String message;
  
  const TaskError({required this.message});
  
  @override
  List<Object> get props => [message];
}

// Add TasksError state
class TasksError extends TaskState {
  final String message;
  
  const TasksError({required this.message});
  
  @override
  List<Object> get props => [message];
}

// Add TaskDetailError state
class TaskDetailError extends TaskState {
  final String message;
  
  const TaskDetailError({required this.message});
  
  @override
  List<Object> get props => [message];
}

// Add TaskDeleted state
class TaskDeleted extends TaskState {}