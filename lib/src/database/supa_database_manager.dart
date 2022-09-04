import 'package:lumberdash/lumberdash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../supa_manager.dart';

const userIdFieldName = 'userId';
const idFieldName = 'id';
const tokenExpired = 'JWT expired';


class SupaDatabaseManager {
  late SupabaseClient client;
  final SupaAuthManager authManager;
  Stream<List<Map<String, dynamic>>>? projectStream;
  Stream<List<Map<String, dynamic>>>? taskStream;

  SupaDatabaseManager(this.authManager) {
    client = Supabase.instance.client;
   }

  Future<List<dynamic>?> _listTable(String tableName) async {
    try {
      final data = await client.from(tableName).select();
      return data;
    } on Exception catch (error) {
      logFatal('Problems listing table $tableName Error: $error');
      if (await _handlePostgrestError(error)) {
        return _listTable(tableName);
      }
    }
    return null;
  }

  Future<List<dynamic>?> addDataToTable(
      String tableName, List<Map<String, dynamic>> tableData) async {
    try {
      final data = await client.from(tableName).insert(tableData).select();
      return data;
    } on Exception catch (error) {
      logFatal('Error adding data $error');
      if (await _handlePostgrestError(error)) {
        return addDataToTable(tableName, tableData);
      }
      return Future.value(null);
    }
  }

  Future<T?> readEntry<T>(TableData<T> tableData, int id) async {
    try {
      final data = await client
          .from(tableData.tableName)
          .select()
          .eq(userIdFieldName, client.auth.currentUser!.id)
          .eq(idFieldName, id)
          .single();
      if (data != null && data.isNotEmpty) {
        return tableData.fromJson(data);
      }
    } on Exception catch (error) {
      logFatal('Error reading data $error');
      if (await _handlePostgrestError(error)) {
        return readEntry(tableData, id);
      }
    }
    return null;
  }

  Future<List<T>> readEntries<T>(TableData<T> tableData) async {
    final entries = <T>[];
    final data = await _listTable(tableData.tableName);
    if (data != null && data.isNotEmpty) {
      for (final json in data) {
        entries.add(tableData.fromJson(json));
      }
    }
    return entries;
  }

  Future<List<T>> readEntriesWhere<T>(
      TableData<T> tableData, String columnName, int id) async {
    final entries = <T>[];
    try {
      final data = await client
          .from(tableData.tableName)
          .select()
          .eq(userIdFieldName, client.auth.currentUser!.id)
          .eq(columnName, id);
      if (data != null && data is List<dynamic> && data.isNotEmpty) {
        await Future.forEach(data, (json) async {
          final entry = tableData.fromJson(json as Map<String, dynamic>);
          entries.add(entry);
        });
        return entries;
      }
    } on Exception catch (error) {
      logFatal('readEntriesWhere: Error  $error');
      if (await _handlePostgrestError(error)) {
        return readEntriesWhere(tableData, columnName, id);
      }
    }
    return entries;
  }

  Future<List<T>> selectEntriesWhere<T>(
      TableData<T> tableData, List<SelectEntry> selections) async {
    final entries = <T>[];
    try {
      var select = client
          .from(tableData.tableName)
          .select()
          .eq(userIdFieldName, client.auth.currentUser!.id);
      var orString = '';
      var orCount = 0;
      var totalOrs = 0;
      for (final element in selections) { if (element.type == SelectType.or) totalOrs++;}
      for (final selection in selections) {
        switch (selection.type) {
          case SelectType.and:
            select = select.eq(selection.columnName, selection.value);
            break;
          case SelectType.or:
            orString += '${selection.columnName}.eq.${selection.value}';
            if (orCount + 1 < totalOrs) {
              orString += ',';
            }
            orCount++;
            break;
        }
      }
      if (orString.isNotEmpty) {
        select = select.or(orString);
      }
      final data = await select;
      if (data != null && data is List<dynamic> && data.isNotEmpty) {
        await Future.forEach(data, (json) async {
          final entry = tableData.fromJson(json as Map<String, dynamic>);
          entries.add(entry);
        });
        return entries;
      }
    } on Exception catch (error) {
      logFatal('readEntriesWhere: Error  $error');
      if (await _handlePostgrestError(error)) {
        return selectEntriesWhere(tableData, selections);
      }
    }
    return entries;
  }

  Future<T?> addEntry<T>(
      TableData<T> tableData, TableEntry<T> tableEntry) async {
    final data = await addDataToTable(
        tableData.tableName, tableEntry.addUserId(client.auth.currentUser!.id));
    if (data != null && data.isNotEmpty) {
      return tableData.fromJson(data[0]);
    }
    return null;
  }

  Future<T?> updateTableEntry<T>(
      TableData<T> tableData, TableEntry<T> tableEntry) async {
    if (tableEntry.id == null) {
      logFatal('updateTableEntry: id is null');
      return null;
    }
    try {
      final data = await client
          .from(tableData.tableName)
          .update(tableEntry.toJson())
          .eq(idFieldName, tableEntry.id)
          .select();
      if (data != null && data is List<dynamic> && data.isNotEmpty) {
        return tableData.fromJson(data[0]);
      }
    } on Exception catch (error) {
      logFatal('updateTableEntry Error: $error');
      if (await _handlePostgrestError(error)) {
        return updateTableEntry(tableData, tableEntry);
      }
    }
    return null;
  }

  Future<T?> deleteTableEntry<T>(
      TableData<T> tableData, TableEntry<T> tableEntry) async {
    if (tableEntry.id == null) {
      logFatal('deleteTableEntry: id is null');
      return null;
    }
    try {
      final data = await client
          .from(tableData.tableName)
          .delete()
          .eq(idFieldName, tableEntry.id)
          .select();

      if (data != null && data is List<dynamic> && data.isNotEmpty) {
        return tableData.fromJson(data[0]);
      }
    } on Exception catch (error) {
      logFatal('deleteTableEntry: $error');
      if (await _handlePostgrestError(error)) {
        return deleteTableEntry(tableData, tableEntry);
      }
    }
    return null;
  }

  Future<bool> _handlePostgrestError(Exception error) async {
    if (error is PostgrestException) {
      if (error.message.contains(tokenExpired)) {
        return authManager.refreshSession();
      }
    }
    return false;
  }
}
