import 'package:get_storage/get_storage.dart';

class StorageService {
  final storage = GetStorage();

  // Key for storing tasks
  static const String tasksKey = 'tasks';

  // Save tasks to local storage
  Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    await storage.write(tasksKey, tasks);
  }

  // Get tasks from local storage
  List<Map<String, dynamic>> getTasks() {
    final tasks = storage.read<List>(tasksKey);
    if (tasks == null) return [];
    return List<Map<String, dynamic>>.from(tasks);
  }
}
