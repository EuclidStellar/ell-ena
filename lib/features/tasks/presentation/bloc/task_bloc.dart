import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ellena/core/di/injection_container.dart';
import 'package:ellena/core/models/task.dart';
import 'package:ellena/core/services/task_service.dart';
import 'package:ellena/core/utils/logger.dart';
import 'package:ellena/features/tasks/presentation/bloc/task_event.dart';
import 'package:ellena/features/tasks/presentation/bloc/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService _taskService = sl<TaskService>();
  final AppLogger _logger = AppLogger();
  
  TaskBloc() : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<LoadTaskDetail>(_onLoadTaskDetail);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskStatus>(_onToggleTaskStatus);
  }
  
  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final List<Task> tasks;
      
      if (event.filterType != null) {
        tasks = await _taskService.getTasksByType(event.filterType!);
      } else {
        tasks = await _taskService.getAllTasks();
      }
      
      // Sort tasks: non-completed first, then by creation date (newest first)
      tasks.sort((a, b) {
        if (a.isDone != b.isDone) {
          return a.isDone ? 1 : -1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });
      
      emit(TasksLoaded(tasks: tasks, filterType: event.filterType));
    } catch (e) {
      _logger.error('Error loading tasks: $e');
      emit(TaskError(message: 'Failed to load tasks'));
    }
  }
  
  Future<void> _onLoadTaskDetail(LoadTaskDetail event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final task = await _taskService.getTaskById(event.taskId);
      
      if (task != null) {
        final relatedTasks = await _taskService.getRelatedTasks(event.taskId);
        emit(TaskDetailLoaded(task: task, relatedTasks: relatedTasks));
      } else {
        emit(const TaskError(message: 'Task not found'));
      }
    } catch (e) {
      _logger.error('Error loading task detail: $e');
      emit(TaskError(message: 'Failed to load task details'));
    }
  }
  
  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    try {
      final success = await _taskService.addTask(event.task);
      
      if (success) {
        add(const LoadTasks());
      } else {
        emit(const TaskError(message: 'Failed to create task'));
      }
    } catch (e) {
      _logger.error('Error creating task: $e');
      emit(TaskError(message: 'Failed to create task: ${e.toString()}'));
    }
  }
  
  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      final success = await _taskService.updateTask(event.task);
      
      if (success) {
        if (state is TaskDetailLoaded) {
          add(LoadTaskDetail(event.task.id));
        } else {
          add(const LoadTasks());
        }
      } else {
        emit(const TaskError(message: 'Failed to update task'));
      }
    } catch (e) {
      _logger.error('Error updating task: $e');
      emit(TaskError(message: 'Failed to update task: ${e.toString()}'));
    }
  }
  
  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      final success = await _taskService.deleteTask(event.taskId);
      
      if (success) {
        add(const LoadTasks());
      } else {
        emit(const TaskError(message: 'Failed to delete task'));
      }
    } catch (e) {
      _logger.error('Error deleting task: $e');
      emit(TaskError(message: 'Failed to delete task: ${e.toString()}'));
    }
  }
  
  Future<void> _onToggleTaskStatus(ToggleTaskStatus event, Emitter<TaskState> emit) async {
    try {
      final success = await _taskService.toggleTaskStatus(event.taskId);
      
      if (success) {
        if (state is TaskDetailLoaded) {
          add(LoadTaskDetail(event.taskId));
        } else {
          add(const LoadTasks());
        }
      } else {
        emit(const TaskError(message: 'Failed to update task status'));
      }
    } catch (e) {
      _logger.error('Error toggling task status: $e');
      emit(TaskError(message: 'Failed to update task status: ${e.toString()}'));
    }
  }
}