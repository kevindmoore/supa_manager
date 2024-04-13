import 'dart:io';

import 'package:lumberdash/lumberdash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/result.dart';
import '../auth/supabase_auth.dart';
import 'select_entry.dart';
import 'table_entry.dart';

const userIdFieldName = 'user_id';
const idFieldName = 'id';
const tokenExpired = 'JWT expired';

typedef SelectBuilder = PostgrestFilterBuilder Function(
    PostgrestFilterBuilder builder);

/// Class for managing Supabase databases
///
/// Depends on [TableData] for describing a table and
/// [TableEntry] for handling the data itself
class SupaDatabaseManager {
  final SupabaseClient client;
  final SupaAuthManager? authManager;
  Stream<List<Map<String, dynamic>>>? projectStream;
  Stream<List<Map<String, dynamic>>>? taskStream;

  /// Initialize with AuthManager. Get an instance of the client
  SupaDatabaseManager(this.authManager, this.client);

  /// Generic method to get all of the values from a table
  ///
  /// [tableName] name of table
  Future<Result<List<dynamic>>> _listTable(String tableName) async {
    try {
      if (authManager?.isLoggedIn() == false) {
        return const Result.errorMessage(1, 'Not logged in');
      }
      final data = await client.from(tableName).select();
      return Result.success(data);
    } on Exception catch (error) {
      logFatal('Problems listing table $tableName Error: $error');
      if (await _handlePostgrestError(error)) {
        return _listTable(tableName);
      }
      return Result.failure(error);
    }
  }

  /// Given a table name and a list of json data, perform an insert
  ///
  /// [tableName] name of table
  /// [tableData] list of mapped data
  Future<Result<List<dynamic>>> addListDataToTable(
      String tableName, List<Map<String, dynamic>> tableData) async {
    try {
      if (authManager?.isLoggedIn() == false) {
        return const Result.errorMessage(1, 'Not logged in');
      }
      final data = await client.from(tableName).insert(tableData).select();
      return Result.success(data);
    } on Exception catch (error) {
      logFatal('Error adding data $error');
      if (await _handlePostgrestError(error)) {
        return addListDataToTable(tableName, tableData);
      }
      return Result.failure(error);
    }
  }

  /// Given a table name and json data, perform an insert
  ///
  /// The name of the table is [tableName]
  /// [tableData] list of mapped data
  Future<Result<dynamic>> addDataToTable(
      String tableName, Map<String, dynamic> tableMap) async {
    try {
      if (authManager?.isLoggedIn() == false) {
        return const Result.errorMessage(1, 'Not logged in');
      }
      final data = await client.from(tableName).insert(tableMap).select();
      return Result.success(data);
    } on Exception catch (error) {
      logFatal('Error adding data $error');
      if (await _handlePostgrestError(error)) {
        return addDataToTable(tableName, tableMap);
      }
      return Result.failure(error);
    }
  }

  /// Read a single entry with the given table data and id
  ///
  /// [tableData] contains table info
  /// [id] id of given entry
  Future<Result<T?>> readEntry<T>(TableData<T> tableData, int id) async {
    try {
      if (authManager?.isLoggedIn() == false) {
        return const Result.errorMessage(1, 'Not logged in');
      }
      var select =
          client.from(tableData.tableName).select().eq(idFieldName, id);
      if (tableData.hasUserId) {
        select = select.eq(userIdFieldName, client.auth.currentUser!.id);
      }
      final data = await select.single();
      // if (data != null && data.isNotEmpty) {
      if (data.isNotEmpty) {
        return Result.success(tableData.fromJson(data));
      }
      return const Result.success(null);
    } on Exception catch (error) {
      logFatal('Error reading data $error');
      if (await _handlePostgrestError(error)) {
        return readEntry(tableData, id);
      }
      return Result.failure(error);
    }
  }

  /// Return a list of entries for the given table
  ///
  /// [tableData] contains table info
  Future<Result<List<T>>> readEntries<T>(TableData<T> tableData) async {
    if (authManager?.isLoggedIn() == false) {
      return const Result.errorMessage(1, 'Not logged in');
    }
    final entries = <T>[];
    final result = await _listTable(tableData.tableName);
    return result.when(success: (data) {
      if (data != null && data.isNotEmpty) {
        for (final json in data) {
          entries.add(tableData.fromJson(json));
        }
      }
      return Result.success(entries);
    }, failure: (error) {
      return Result.failure(error);
    }, errorMessage: (code, message) {
      return Result.errorMessage(code, message);
    });
  }

  /// Return a list of entries for the given table
  ///
  /// [functionName] Name of function to run
  Future<Result<List<dynamic>>> runFunction(String functionName) async {
    if (authManager?.isLoggedIn() == false) {
      return const Result.errorMessage(1, 'Not logged in');
    }
    try {
      final result = await client.rpc(functionName);
      return Result.success(result);
    } on Exception catch (error) {
      logFatal('buildSelect: Error  $error');
      if (await _handlePostgrestError(error)) {
        return runFunction(functionName);
      }
      return Result.failure(error);
    }
  }

  /// Return a list of entries for the given table that matches a single column
  ///
  /// [tableData] contains table info
  /// [columnName] column name
  /// [columnValue] value of column to match
  Future<Result<List<T>>> readEntriesWhere<T>(
      TableData<T> tableData, String columnName, Object columnValue) async {
    final entries = <T>[];
    if (authManager?.isLoggedIn() == false) {
      return const Result.errorMessage(1, 'Not logged in');
    }
    try {
      var select =
          client.from(tableData.tableName).select().eq(columnName, columnValue);
      if (tableData.hasUserId) {
        select = select.eq(userIdFieldName, client.auth.currentUser!.id);
      }
      final data = await select;
      // if (data != null && data is List<dynamic> && data.isNotEmpty) {
      if (data.isNotEmpty) {
        await Future.forEach(data, (json) async {
          final entry = tableData.fromJson(json as Map<String, dynamic>);
          entries.add(entry);
        });
      }
      return Result.success(entries);
    } on Exception catch (error) {
      logFatal('readEntriesWhere: Error  $error');
      if (await _handlePostgrestError(error)) {
        return readEntriesWhere(tableData, columnName, columnValue);
      }
      return Result.failure(error);
    }
  }

  /// Return a list of entries for the given table. Pass in a builder
  /// to add your own selection statements
  ///
  /// [tableData] contains table info
  /// [builder] function for adding additional selection statements
  Future<Result<List<T>>> buildSelect<T>(
      TableData<T> tableData, SelectBuilder builder) async {
    if (authManager?.isLoggedIn() == false) {
      return const Result.errorMessage(1, 'Not logged in');
    }
    final entries = <T>[];
    try {
      var select = client.from(tableData.tableName).select();
      if (tableData.hasUserId) {
        select = select.eq(userIdFieldName, client.auth.currentUser!.id);
      }
      select = builder.call(select)
          as PostgrestFilterBuilder<List<Map<String, dynamic>>>;
      final data = await select;
      // if (data != null && data is List<dynamic> && data.isNotEmpty) {
      if (data.isNotEmpty) {
        await Future.forEach(data, (json) async {
          final entry = tableData.fromJson(json as Map<String, dynamic>);
          entries.add(entry);
        });
      }
      return Result.success(entries);
    } on Exception catch (error) {
      logFatal('buildSelect: Error  $error');
      if (await _handlePostgrestError(error)) {
        return buildSelect(tableData, builder);
      }
      return Result.failure(error);
    }
  }

  /// Return a list of entries for the given table that matches a list of selection entries
  ///
  /// [tableData] contains table info
  /// [selections] list of [SelectEntry] items
  Future<Result<List<T>>> selectEntriesWhere<T>(
      TableData<T> tableData, List<SelectEntry> selections) async {
    if (authManager?.isLoggedIn() == false) {
      return const Result.errorMessage(1, 'Not logged in');
    }
    final entries = <T>[];
    try {
      var select = client.from(tableData.tableName).select();
      if (tableData.hasUserId) {
        select = select.eq(userIdFieldName, client.auth.currentUser!.id);
      }
      for (final selection in selections) {
        if (selection.type == SelectType.and) {
          select = select.eq(selection.columnName, selection.value);
        }
      }
      final orString = buildOrString(selections);
      if (orString.isNotEmpty) {
        select = select.or(orString);
      }
      final data = await select;
      // if (data != null && data is List<dynamic> && data.isNotEmpty) {
      if (data.isNotEmpty) {
        await Future.forEach(data, (json) async {
          final entry = tableData.fromJson(json as Map<String, dynamic>);
          entries.add(entry);
        });
      }
      return Result.success(entries);
    } on Exception catch (error) {
      logFatal('selectEntriesWhere: Error  $error');
      if (await _handlePostgrestError(error)) {
        return selectEntriesWhere(tableData, selections);
      }
      return Result.failure(error);
    }
  }

  /// Helper function to build an or string for selections
  ///
  /// [selections] list of [SelectEntry] items
  String buildOrString(List<SelectEntry> selections) {
    var orString = '';
    var orCount = 0;
    var totalOrs = 0;
    for (final element in selections) {
      if (element.type == SelectType.or) totalOrs++;
    }
    for (final selection in selections) {
      if (selection.type == SelectType.or) {
        orString += '${selection.columnName}.eq.${selection.value}';
        if (orCount + 1 < totalOrs) {
          orString += ',';
        }
        orCount++;
      }
    }
    return orString;
  }

  /// Add a single entry for the given table.
  ///
  /// [tableData] Describe Table
  /// [tableEntry] contains table entry
  Future<Result<T?>> addEntry<T>(
      TableData<T> tableData, TableEntry<T> tableEntry) async {
    if (authManager?.isLoggedIn() == false) {
      return const Result.errorMessage(1, 'Not logged in');
    }
    final updatedEntry = tableEntry.addUserId(client.auth.currentUser!.id);
    final result =
        await addDataToTable(tableData.tableName, updatedEntry.toJson());
    return result.when(success: (data) {
      if (data != null && data.isNotEmpty) {
        return Result.success(tableData.fromJson(data[0]));
      }
      return const Result.success(null);
    }, failure: (error) {
      logFatal('addEntry: Error  $error');
      return Result.failure(error);
    }, errorMessage: (code, message) {
      logFatal('addEntry: Error  $message');
      return Result.errorMessage(code, message);
    });
  }

  /// For the given table, add a list of entries
  ///
  /// [tableData] Describe Table
  /// [tableEntries] list of table entries
  Future<Result<List<T>>> addEntries<T>(
      TableData<T> tableData, List<TableEntry<T>> tableEntries) async {
    if (authManager?.isLoggedIn() == false) {
      return const Result.errorMessage(1, 'Not logged in');
    }
    final jsonEntries = <Map<String, dynamic>>[];
    for (final entry in tableEntries) {
      final updatedEntry = entry.addUserId(client.auth.currentUser!.id);
      jsonEntries.add(updatedEntry.toJson());
    }
    final result = await addListDataToTable(tableData.tableName, jsonEntries);
    return result.when(success: (data) {
      final addedEntries = <T>[];
      if (data != null && data.isNotEmpty) {
        for (final entry in data) {
          addedEntries.add(tableData.fromJson(entry));
        }
        return Result.success(addedEntries);
      }
      return Result.success(addedEntries);
    }, failure: (error) {
      logFatal('addEntries: Error  $error');
      return Result.failure(error);
    }, errorMessage: (code, message) {
      logFatal('addEntries: Error  $message');
      return Result.errorMessage(code, message);
    });
  }

  /// Update a single table entry
  ///
  /// [tableData] Describe Table
  /// [tableEntry] Describe data
  Future<Result<T?>> updateTableEntry<T>(
      TableData<T> tableData, TableEntry<T> tableEntry) async {
    if (authManager?.isLoggedIn() == false) {
      return const Result.errorMessage(1, 'Not logged in');
    }
    if (tableEntry.id == null) {
      logFatal('updateTableEntry: id is null');
      return const Result.errorMessage(1, 'Table Entry id is null');
    }
    try {
      final data = await client
          .from(tableData.tableName)
          .update(tableEntry.toJson())
          .eq(idFieldName, tableEntry.id!)
          .select();
      // if (data != null && data is List<dynamic> && data.isNotEmpty) {
      if (data.isNotEmpty) {
        return Result.success(tableData.fromJson(data[0]));
      }
      return const Result.success(null);
    } on Exception catch (error) {
      logFatal('updateTableEntry Error: $error');
      if (await _handlePostgrestError(error)) {
        return updateTableEntry(tableData, tableEntry);
      }
      return Result.failure(error);
    }
  }

  /// Delete a single table entry
  ///
  /// [tableData] Describe Table
  /// [tableEntry] Describe data
  Future<Result<T?>> deleteTableEntry<T>(
      TableData<T> tableData, TableEntry<T> tableEntry) async {
    if (authManager?.isLoggedIn() == false) {
      return const Result.errorMessage(1, 'Not logged in');
    }
    if (tableEntry.id == null) {
      logFatal('deleteTableEntry: id is null');
      return const Result.errorMessage(1, 'deleteTableEntry id is null');
    }
    try {
      final data = await client
          .from(tableData.tableName)
          .delete()
          .eq(idFieldName, tableEntry.id!)
          .select();

      // if (data != null && data is List<dynamic> && data.isNotEmpty) {
      if (data.isNotEmpty) {
        return Result.success(tableData.fromJson(data[0]));
      }
      return const Result.success(null);
    } on Exception catch (error) {
      logFatal('deleteTableEntry: $error');
      if (await _handlePostgrestError(error)) {
        return deleteTableEntry(tableData, tableEntry);
      }
      return Result.failure(error);
    }
  }

  /// Delete all table entries. WARNING: This will delete all entries
  Future<Result<T?>> deleteAll<T>(TableData<T> tableData) async {
    if (authManager?.isLoggedIn() == false) {
      return const Result.errorMessage(1, 'Not logged in');
    }
    try {
      // NOTE: Requires where clause. Use a value that will always be true
      await client.from(tableData.tableName).delete().neq(idFieldName, -1);
      return const Result.success(null);
    } on Exception catch (error) {
      logFatal('deleteTableEntry: $error');
      if (await _handlePostgrestError(error)) {
        return deleteAll(tableData);
      }
      return Result.failure(error);
    }
  }

  Future<Result<String?>> uploadFile(
      String bucket, String folderName, String fileName, File file) async {
    if (authManager?.isLoggedIn() == false) {
      return const Result.errorMessage(1, 'Not logged in');
    }
    try {
      final path = await client.storage.from(bucket).updateBinary(
            '$folderName/$fileName',
            file.readAsBytesSync(),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      // Doesn't work on web
      // final path = await client.storage.from(bucket).upload(
      //   '$folderName/$fileName',
      //   file,
      //   fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      // );
      return Result.success(path);
    } on Exception catch (error) {
      logFatal('uploadFile: $error');
      return Result.failure(error);
    }
  }

  Future<Result<bool>> downloadFile(
      String bucket, String folderName, String fileName, File file) async {
    if (authManager?.isLoggedIn() == false) {
      return const Result.errorMessage(1, 'Not logged in');
    }
    try {
      final u8List = await client.storage.from(bucket).download(
            '$folderName/$fileName',
          );
      file.writeAsBytesSync(u8List);
      return const Result.success(true);
    } on Exception catch (error) {
      logFatal('downloadFile: $error');
      return Result.failure(error);
    }
  }

  Future<Result<List<FileObject>?>> deleteFile(
      String bucket, String folderName, String fileName) async {
    if (authManager?.isLoggedIn() == false) {
      return const Result.errorMessage(1, 'Not logged in');
    }
    try {
      final files = await client.storage.from(bucket).remove(
        ['$folderName/$fileName'],
      );
      return Result.success(files);
    } on Exception catch (error) {
      logFatal('deleteFile: $error');
      return Result.failure(error);
    }
  }

  Future<Result<List<FileObject>?>> getBucketList(
      String bucket, String path) async {
    if (authManager?.isLoggedIn() == false) {
      return const Result.errorMessage(1, 'Not logged in');
    }
    try {
      final files = await client.storage.from(bucket).list(path: path);
      return Result.success(files);
    } on Exception catch (error) {
      logFatal('getBucketList: $error');
      return Result.failure(error);
    }
  }

  /// Check to see if the token has expired. Refresh
  /// [error] Exception. Could be PostgrestException
  Future<bool> _handlePostgrestError(Exception error) async {
    if (error is PostgrestException) {
      logError('PostgrestException: ${error.message}');
      if (error.message.contains(tokenExpired) && authManager != null) {
        return authManager!.refreshSession();
      } else if (authManager != null) {
        return authManager!.refreshSession();
      }
    }
    return false;
  }
}
