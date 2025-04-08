import 'dart:convert';
import 'package:ellena/core/models/chat_message.dart';
import 'package:ellena/core/models/project.dart';
import 'package:ellena/core/models/task.dart';
import 'package:ellena/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;
  final AppLogger _logger = AppLogger();

  // Storage keys
  static const String _tasksKey = 'tasks';
  static const String _projectsKey = 'projects';
  static const String _messagesKey = 'messages';

  LocalStorageService(this._prefs);

  // Task methods
  Future<bool> saveTasks(List<Task> tasks) async {
    try {
      final tasksJson = tasks.map((task) => task.toJson()).toList();
      return await _prefs.setString(_tasksKey, jsonEncode(tasksJson));
    } catch (e) {
      _logger.error('Error saving tasks: $e');
      return false;
    }
  }

  List<Task> getTasks() {
    try {
      final tasksString = _prefs.getString(_tasksKey);
      if (tasksString == null) return [];
      
      final tasksList = jsonDecode(tasksString) as List;
      return tasksList.map((item) => Task.fromJson(item)).toList();
    } catch (e) {
      _logger.error('Error getting tasks: $e');
      return [];
    }
  }

  Future<bool> addTask(Task task) async {
    final tasks = getTasks();
    tasks.add(task);
    return await saveTasks(tasks);
  }

  Future<bool> updateTask(Task task) async {
    final tasks = getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    
    if (index >= 0) {
      tasks[index] = task;
      return await saveTasks(tasks);
    }
    return false;
  }

  Future<bool> deleteTask(String taskId) async {
    final tasks = getTasks();
    tasks.removeWhere((task) => task.id == taskId);
    return await saveTasks(tasks);
  }

  // Project methods
  Future<bool> saveProjects(List<Project> projects) async {
    try {
      final projectsJson = projects.map((project) => project.toJson()).toList();
      return await _prefs.setString(_projectsKey, jsonEncode(projectsJson));
    } catch (e) {
      _logger.error('Error saving projects: $e');
      return false;
    }
  }

  List<Project> getProjects() {
    try {
      final projectsString = _prefs.getString(_projectsKey);
      if (projectsString == null) return [];
      
      final projectsList = jsonDecode(projectsString) as List;
      return projectsList.map((item) => Project.fromJson(item)).toList();
    } catch (e) {
      _logger.error('Error getting projects: $e');
      return [];
    }
  }

  Future<bool> addProject(Project project) async {
    final projects = getProjects();
    projects.add(project);
    return await saveProjects(projects);
  }

  // Chat message methods
  Future<bool> saveMessages(List<ChatMessage> messages) async {
    try {
      final messagesJson = messages.map((message) => message.toJson()).toList();
      return await _prefs.setString(_messagesKey, jsonEncode(messagesJson));
    } catch (e) {
      _logger.error('Error saving messages: $e');
      return false;
    }
  }

  List<ChatMessage> getMessages() {
    try {
      final messagesString = _prefs.getString(_messagesKey);
      if (messagesString == null) return [];
      
      final messagesList = jsonDecode(messagesString) as List;
      return messagesList.map((item) => ChatMessage.fromJson(item)).toList();
    } catch (e) {
      _logger.error('Error getting messages: $e');
      return [];
    }
  }

  Future<bool> addMessage(ChatMessage message) async {
    final messages = getMessages();
    messages.add(message);
    return await saveMessages(messages);
  }

  // Clear all data
  Future<bool> clearAllData() async {
    try {
      await _prefs.remove(_tasksKey);
      await _prefs.remove(_projectsKey);
      await _prefs.remove(_messagesKey);
      return true;
    } catch (e) {
      _logger.error('Error clearing data: $e');
      return false;
    }
  }
}