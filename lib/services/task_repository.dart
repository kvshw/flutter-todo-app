import 'package:get_storage/get_storage.dart';
import '../models/task_model.dart';

/// Repository class for handling task storage operations
class TaskRepository {
  final _storage = GetStorage();
  static const String _tasksKey = 'tasks';

  /// Saves a task to storage
  Future<void> saveTask(Task task) async {
    final tasks = await getAllTasks();
    final existingIndex = tasks.indexWhere((t) => t.id == task.id);

    if (existingIndex >= 0) {
      tasks[existingIndex] = task;
    } else {
      tasks.add(task);
    }

    await _storage.write(_tasksKey, tasks.map((t) => t.toJson()).toList());
  }

  /// Retrieves all tasks from storage
  Future<List<Task>> getAllTasks() async {
    final tasksJson = _storage.read<List>(_tasksKey);
    if (tasksJson == null) return [];

    return List<Map<String, dynamic>>.from(tasksJson)
        .map((json) => Task.fromJson(json))
        .toList();
  }

  /// Deletes a task by ID
  Future<void> deleteTask(String id) async {
    final tasks = await getAllTasks();
    tasks.removeWhere((task) => task.id == id);
    await _storage.write(_tasksKey, tasks.map((t) => t.toJson()).toList());
  }

  /// Marks a task as completed or uncompleted
  Future<void> toggleTaskCompletion(String id) async {
    final tasks = await getAllTasks();
    final taskIndex = tasks.indexWhere((task) => task.id == id);

    if (taskIndex >= 0) {
      final task = tasks[taskIndex];
      tasks[taskIndex] = task.copyWith(isCompleted: !task.isCompleted);
      await _storage.write(_tasksKey, tasks.map((t) => t.toJson()).toList());
    }
  }

  /// Updates a task's title and/or description
  Future<void> updateTask({
    required String id,
    String? title,
    String? description,
  }) async {
    final tasks = await getAllTasks();
    final taskIndex = tasks.indexWhere((task) => task.id == id);

    if (taskIndex >= 0) {
      final task = tasks[taskIndex];
      tasks[taskIndex] = task.copyWith(
        title: title,
        description: description,
      );
      await _storage.write(_tasksKey, tasks.map((t) => t.toJson()).toList());
    }
  }
}
