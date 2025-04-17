import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/task_model.dart';
import '../services/task_repository.dart';

/// Controller class for managing tasks using GetX state management
class TaskController extends GetxController {
  final TaskRepository _repository;
  final _storage = GetStorage();

  /// Observable list of tasks
  final RxList<Task> tasks = <Task>[].obs;

  /// Loading state
  final RxBool isLoading = false.obs;

  /// Error message
  final RxString errorMessage = ''.obs;

  TaskController({TaskRepository? repository})
      : _repository = repository ?? TaskRepository();

  @override
  void onInit() {
    super.onInit();
    _loadTasks();
  }

  void _loadTasks() {
    try {
      final storedTasks = _storage.read<List>('tasks') ?? [];
      tasks.value = storedTasks.map((task) => Task.fromJson(task)).toList();
    } catch (e) {
      errorMessage.value = 'Failed to load tasks: $e';
    }
  }

  Future<void> _saveTasks() async {
    try {
      await _storage.write(
          'tasks', tasks.map((task) => task.toJson()).toList());
    } catch (e) {
      errorMessage.value = 'Failed to save tasks: $e';
      rethrow;
    }
  }

  /// Loads all tasks from storage
  Future<void> loadTasks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final loadedTasks = await _repository.getAllTasks();
      tasks.assignAll(loadedTasks);
    } catch (e) {
      errorMessage.value = 'Failed to load tasks: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Adds a new task
  Future<void> addTask({
    required String title,
    String description = '',
  }) async {
    try {
      isLoading.value = true;
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
      );
      tasks.add(task);
      await _saveTasks();
      Get.back();
      Get.snackbar(
        'Success',
        'Task created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.2),
        colorText: Colors.green,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create task: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: Colors.red,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(Icons.error, color: Colors.red),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates an existing task
  Future<void> updateTask({
    required String id,
    required String title,
    String description = '',
  }) async {
    try {
      isLoading.value = true;
      final index = tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        tasks[index] = Task(
          id: id,
          title: title,
          description: description,
          isCompleted: tasks[index].isCompleted,
        );
        await _saveTasks();
        Get.back();
        Get.snackbar(
          'Success',
          'Task updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.withOpacity(0.2),
          colorText: Colors.blue,
          duration: Duration(seconds: 2),
          margin: EdgeInsets.all(16),
          borderRadius: 12,
          icon: Icon(Icons.check_circle, color: Colors.blue),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: Colors.red,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(Icons.error, color: Colors.red),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Deletes a task
  Future<void> deleteTask(String id) async {
    try {
      tasks.removeWhere((task) => task.id == id);
      await _saveTasks();
      Get.snackbar(
        'Success',
        'Task deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.2),
        colorText: Colors.orange,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(Icons.delete_forever, color: Colors.orange),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete task: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: Colors.red,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(Icons.error, color: Colors.red),
      );
    }
  }

  /// Toggles task completion status
  Future<void> toggleTaskCompletion(String id) async {
    try {
      final index = tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        final task = tasks[index];
        tasks[index] = Task(
          id: task.id,
          title: task.title,
          description: task.description,
          isCompleted: !task.isCompleted,
        );
        await _saveTasks();
        Get.snackbar(
          'Success',
          tasks[index].isCompleted ? 'Task completed' : 'Task uncompleted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: tasks[index].isCompleted
              ? Colors.green.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
          colorText: tasks[index].isCompleted ? Colors.green : Colors.grey,
          duration: Duration(seconds: 1),
          margin: EdgeInsets.all(16),
          borderRadius: 12,
          icon: Icon(
            tasks[index].isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: tasks[index].isCompleted ? Colors.green : Colors.grey,
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: Colors.red,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(Icons.error, color: Colors.red),
      );
    }
  }

  /// Returns a list of completed tasks
  List<Task> get completedTasks =>
      tasks.where((task) => task.isCompleted).toList();

  /// Returns a list of pending tasks
  List<Task> get pendingTasks =>
      tasks.where((task) => !task.isCompleted).toList();

  /// Returns task statistics
  Map<String, int> get statistics => {
        'total': tasks.length,
        'completed': completedTasks.length,
        'pending': pendingTasks.length,
      };
}
