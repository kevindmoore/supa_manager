import 'package:lumberdash/lumberdash.dart';

import '../../supa_manager.dart';

/// Holds the table name and a method to convert a json map to a class
abstract class TableData<T> {
  late String tableName;

  bool hasUserId = true;

  T fromJson(Map<String, dynamic> json);
}

class TableDataImpl<T> extends TableData<T> {
  final T Function(Map<String, dynamic> json) fromJsonFunction;

  TableDataImpl(String tableName, this.fromJsonFunction) {
    this.tableName = tableName;
  }

  @override
  T fromJson(Map<String, dynamic> json) => fromJsonFunction(json);

  Future<T?> getEntry(SupaDatabaseManager databaseRepository,
      int id) async {
    final result = await databaseRepository.readEntry(this, id);
    switch (result) {
      case Success(data: final data):
        return data;
      case Failure(error: final error):
        logFatal('getEntry: Error  $error');
        return null;
      case ErrorMessage(message: final message):
        logFatal('getEntry: Error  $message');
        return null;
    }
  }

  Future<List<T>> getEntries(SupaDatabaseManager databaseRepository,
      ) async {
    final result = await databaseRepository.readEntries(this);
    switch (result) {
      case Success(data: final data):
        return data;
      case Failure(error: final error):
        logFatal('getEntries: Error  $error');
        return [];
      case ErrorMessage(message: final message):
        logFatal('getEntries: Error  $message');
        return [];
    }
  }
}

/// Implement this mixin to implement the `toJson` and `addUserId` methods
/// If you do not use a user id, then just return the same class
mixin TableEntry<T> {
  abstract int? id;

  Map<String, dynamic> toJson();

  TableEntry<T> addUserId(String userId);
}

typedef IDFunction = int Function();
typedef ToJsonFunction = Map<String, dynamic> Function();
typedef CopyFunction<T> = T Function(String);

class TableEntryImpl<T> with TableEntry<T> {
  final T data;
  final IDFunction idFunction;
  final ToJsonFunction toJsonFunction;
  final CopyFunction copyFunction;

  TableEntryImpl(
      this.data, this.idFunction, this.toJsonFunction, this.copyFunction);

  @override
  int? get id => idFunction();

  @override
  Map<String, dynamic> toJson() => toJsonFunction();

  @override
  set id(int? id) {}

  @override
  TableEntry<T> addUserId(String userId) {
    return TableEntryImpl(
        copyFunction(userId), idFunction, toJsonFunction, copyFunction);
  }

  Future<T?> addEntry(
      SupaDatabaseManager databaseRepository, TableData<T> tableData) async {
    final result = await databaseRepository.addEntry(tableData, this);
    switch (result) {
      case Success(data: final data):
        return data;
      case Failure(error: final error):
        logFatal('addEntry: Error  $error');
        return null;
      case ErrorMessage(message: final message):
        logFatal('addEntry: Error  $message');
        return null;
    }
  }

  Future<T?> updateEntry(
      SupaDatabaseManager databaseRepository, TableData<T> tableData) async {
    final result = await databaseRepository.updateTableEntry(tableData, this);
    switch (result) {
      case Success(data: final data):
        return data;
      case Failure(error: final error):
        logFatal('updateEntry: Error  $error');
        return null;
      case ErrorMessage(message: final message):
        logFatal('updateEntry: Error  $message');
        return null;
    }
  }

  Future<T?> deleteEntry(
      SupaDatabaseManager databaseRepository, TableData<T> tableData) async {
    final result = await databaseRepository.deleteTableEntry(tableData, this);
    switch (result) {
      case Success(data: final data):
        return data;
      case Failure(error: final error):
        logFatal('deleteEntry: Error  $error');
        return null;
      case ErrorMessage(message: final message):
        logFatal('deleteEntry: Error  $message');
        return null;
    }
  }
}

/// Mixin for a table id
mixin HasId {
  int? get tableId;
}

mixin HasCopyWith<T> {
  T copyWith(String userId);
}

mixin HastoJson<T> {
  Map<String, dynamic> toJson();
}

mixin HasfromJson<T> {
  T fromJson(Map<String, dynamic> json);
}

/// Mixin for a user id
mixin HasUserId {
  String? get userId;
}

/// Mixin for a class that has a copyWith method
// mixin hasCopyWith<T> {
//   T get copyWith;
// }

/// Definition of a function that takes data and returns a TableEntry class
typedef TableEntryCreator<T> = TableEntry<T> Function(T data);
