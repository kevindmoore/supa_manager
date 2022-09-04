import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supa_manager/supa_manager.dart';

import '../main.dart';
import 'models/categories.dart';
import 'models/tasks.dart';

typedef TodoFilter = bool Function(Task);

final repositoryProvider = ChangeNotifierProvider<Repository>((ref) {
  return Repository(ref);
});

class Repository extends ChangeNotifier {
  final ChangeNotifierProviderRef ref;
  late SupaDatabaseManager databaseRepository;

  TableData<Task> taskTableData = TaskTableData();
  TableData<Category> categoryTableData = CategoryTableData();

  Repository(this.ref) {
    databaseRepository = getSupaDatabaseManager(ref);
  }

  Future<Task?> addTask(Task task) async {
    final result = await databaseRepository.addEntry(taskTableData, TaskTableEntry(task));
    notifyListeners();
    return result;
  }

  Future<Category?> addCategory(Category category) async {
    final result = await databaseRepository.addEntry(
        categoryTableData, CategoryTableEntry(category));
    notifyListeners();
    return result;
  }

  Future<Category?> deleteCategory(Category category) async {
    final result = await databaseRepository.deleteTableEntry(
        categoryTableData, CategoryTableEntry(category));
    notifyListeners();
    return result;
  }

  Future<Task?> deleteTask(Task task) async {
    final result = await databaseRepository.deleteTableEntry(
        taskTableData, TaskTableEntry(task));
    notifyListeners();
    return result;
  }

  Future<List<Task>> getTasks() async {
    return databaseRepository.readEntries(taskTableData);
  }

  Future<List<Task>> getTodaysTasks() async {
    return databaseRepository.selectEntriesWhere(taskTableData, [SelectEntry.and('done', 'false'),
      SelectEntry.and('doLater', 'false')]);
  }

  Future<List<Task>> getDoneTasks() async {
    return databaseRepository.selectEntriesWhere(taskTableData, [SelectEntry.and('done', 'true'),
      SelectEntry.and('doLater', 'false')]);
  }

  Future<List<Task>> getDoLaterTasks() async {
    return databaseRepository.selectEntriesWhere(taskTableData, [SelectEntry.and('done', 'false'),
      SelectEntry.and('doLater', 'true')]);
  }

  Future<List<Category>> readAllCategories() async {
    return databaseRepository.readEntries(categoryTableData);
  }

  Future<Task?> updateTask(Task task) async {
    final result = await databaseRepository.updateTableEntry(
        taskTableData, TaskTableEntry(task));
    notifyListeners();
    return result;
  }

}

/// Table Entry classes
const taskTableName = 'TodayTasks';
const categoryTableName = 'TodayCategory';

class TaskTableData extends TableData<Task> {
  TaskTableData() {
    tableName = taskTableName;
  }

  @override
  Task fromJson(Map<String, dynamic> json) {
    return Task.fromJson(json);
  }
}

class TaskTableEntry extends TableEntry<Task> {
  final Task task;

  TaskTableEntry(this.task);

  @override
  List<Map<String, dynamic>> addUserId(String userId) {
    return taskToDatabaseJson(task, userId);
  }

  @override
  Map<String, dynamic> toJson() {
    return task.toJson();
  }

  @override
  int? get id => task.id;

  @override
  set id(int? id) {}
}

class CategoryTableData extends TableData<Category> {
  CategoryTableData() {
    tableName = categoryTableName;
  }

  @override
  Category fromJson(Map<String, dynamic> json) {
    return Category.fromJson(json);
  }
}

class CategoryTableEntry extends TableEntry<Category> {
  final Category category;

  CategoryTableEntry(this.category);

  @override
  List<Map<String, dynamic>> addUserId(String userId) {
    return categoryToDatabaseJson(category, userId);
  }

  @override
  Map<String, dynamic> toJson() {
    return category.toJson();
  }

  @override
  int? get id => category.id;

  @override
  set id(int? id) {}
}
