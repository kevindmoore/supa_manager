

import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/tasks.dart';
import 'repository.dart';

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier(ref.read(repositoryProvider));
});


typedef TodoFilter = bool Function(Task);

class TaskNotifier extends StateNotifier<List<Task>> {
  final Repository repository;
  TaskNotifier(this.repository): super(<Task>[]);

  void initialize() async {
    final result = await repository.getTasks();
    result.when(success: (data) {
      state = data;
    }, failure: (Exception error) {
      log('Problems getting tasks', error: error);
    }, errorMessage: (int code, String? message) {
      log('Problems getting tasks: $message');
    });
  }
  void addTask(Task task) {
    state = [...state, task];
  }

  void removeTask(Task taskToRemove) {
    state = [
      for (final task in state)
        if (task.id != taskToRemove.id) task,
    ];
  }

  void replaceTask(Task taskToReplace) {
    final index = state.indexWhere((element) => element.id == taskToReplace.id);
    if (index == -1) {
      log('Task not found: $taskToReplace');
      return;
    }
    final copyOfState = [...state];
    copyOfState[index] = taskToReplace;
    state = copyOfState;
  }

  List<Task> filterTasks(List<Task> data, TodoFilter filter) {
    final tasks = <Task>[];
    for (final task in data) {
      if (filter(task)) {
        tasks.add(task);
      }
    }
    return tasks;
  }

  List<Task> filterTodayTasks(List<Task> data) {
    return filterTasks(data, (task) {
      return (false == task.done && false == task.doLater);
    });
  }

  List<Task> filterDoneTasks(List<Task> data) {
    return filterTasks(data, (task) {
      return (true == task.done && false == task.doLater);
    });
  }

  List<Task> filterDoLaterTasks(List<Task> data) {
    return filterTasks(data, (task) {
      return (false == task.done && true == task.doLater);
    });
  }

}