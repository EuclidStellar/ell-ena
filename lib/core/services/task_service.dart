import 'package:ellena/core/models/task.dart';
import 'package:ellena/core/services/local_storage_service.dart';

class TaskService {
  final LocalStorageService _storageService;

  TaskService(this._storageService);

  Future<List<Task>> getAllTasks() async {
    return _storageService.getTasks();
  }

  Future<List<Task>> getTasksByType(TaskType type) async {
    final tasks = _storageService.getTasks();
    return tasks.where((task) => task.type == type).toList();
  }

  Future<List<Task>> getTasksByTag(String tag) async {
    final tasks = _storageService.getTasks();
    return tasks.where((task) => task.tags.contains(tag)).toList();
  }

  Future<Task?> getTaskById(String id) async {
    final tasks = _storageService.getTasks();
    try {
      return tasks.firstWhere((task) => task.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> addTask(Task task) async {
    return await _storageService.addTask(task);
  }

  Future<bool> updateTask(Task task) async {
    return await _storageService.updateTask(task);
  }

  Future<bool> deleteTask(String taskId) async {
    return await _storageService.deleteTask(taskId);
  }

  Future<bool> toggleTaskStatus(String taskId) async {
    final task = await getTaskById(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(isDone: !task.isDone);
      return await updateTask(updatedTask);
    }
    return false;
  }

  Future<List<Task>> getRelatedTasks(String taskId) async {
    final mainTask = await getTaskById(taskId);
    if (mainTask == null) return [];
    
    final allTasks = await getAllTasks();
    final relatedTasks = <Task>[];
    
    // Get directly related tasks
    for (final id in mainTask.relatedTaskIds) {
      final task = allTasks.firstWhere(
        (t) => t.id == id, 
        orElse: () => throw Exception('Related task not found')
      );
      relatedTasks.add(task);
    }
    
    // Also find tasks that reference this task
    final referencingTasks = allTasks.where(
      (t) => t.id != taskId && t.relatedTaskIds.contains(taskId)
    ).toList();
    
    relatedTasks.addAll(referencingTasks);
    return relatedTasks;
  }
}