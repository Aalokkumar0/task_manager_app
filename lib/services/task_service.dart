import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskService {
  TaskService._();
  static final TaskService instance = TaskService._();

  Future<List<TaskModel>> getTasks() async {
    final response = await ApiService.instance.get('/tasks');
    return ApiService.parseTasks(response.data);
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final response = await ApiService.instance.post(
      '/tasks',
      data: task.toJson(),
    );
    return ApiService.parseTask(response.data);
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final response = await ApiService.instance.put(
      '/tasks/${task.id}',
      data: task.toJson(),
    );
    return ApiService.parseTask(response.data);
  }

  Future<void> deleteTask(String id) async {
    await ApiService.instance.delete('/tasks/$id');
  }
}
