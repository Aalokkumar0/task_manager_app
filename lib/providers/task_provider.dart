import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskNotifier extends AsyncNotifier<List<TaskModel>> {
  @override
  Future<List<TaskModel>> build() async {
    return TaskService.instance.getTasks();
  }

  Future<void> fetchTasks() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(TaskService.instance.getTasks);
  }

  Future<void> addTask(TaskModel task) async {
    final created = await AsyncValue.guard(
      () => TaskService.instance.createTask(task),
    );
    created.whenData((t) {
      state = AsyncData([...?state.valueOrNull, t]);
    });
  }

  Future<void> editTask(TaskModel task) async {
    final updated = await AsyncValue.guard(
      () => TaskService.instance.updateTask(task),
    );
    updated.whenData((t) {
      final current = List<TaskModel>.from(state.valueOrNull ?? []);
      final idx = current.indexWhere((e) => e.id == t.id);
      if (idx != -1) {
        current[idx] = t;
        state = AsyncData(current);
      }
    });
  }

  Future<void> removeTask(String id) async {
    await TaskService.instance.deleteTask(id);
    final current = List<TaskModel>.from(state.valueOrNull ?? []);
    current.removeWhere((e) => e.id == id);
    state = AsyncData(current);
  }
}

final tasksProvider = AsyncNotifierProvider<TaskNotifier, List<TaskModel>>(
  TaskNotifier.new,
);
