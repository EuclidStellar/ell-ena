import 'package:equatable/equatable.dart';
import 'package:ellena/core/models/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final TaskType? filterType;
  
  const LoadTasks({this.filterType});
  
  @override
  List<Object?> get props => [filterType];
}

class LoadTaskDetail extends TaskEvent {
  final String taskId;
  
  const LoadTaskDetail(this.taskId);
  
  @override
  List<Object> get props => [taskId];
}

class CreateTask extends TaskEvent {
  final Task task;
  
  const CreateTask(this.task);
  
  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;
  
  const UpdateTask(this.task);
  
  @override
  List<Object> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  
  const DeleteTask(this.taskId);
  
  @override
  List<Object> get props => [taskId];
}

class ToggleTaskStatus extends TaskEvent {
  final String taskId;
  
  const ToggleTaskStatus(this.taskId);
  
  @override
  List<Object> get props => [taskId];
}