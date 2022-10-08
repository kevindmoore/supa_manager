/// Holds the table name and a method to convert a json map to a class
abstract class TableData<T> {
  late String tableName;

  bool hasUserId = true;

  T fromJson(Map<String, dynamic> json);
}

/// Implement this mixin to implement the `toJson` and `addUserId` methods
/// If you do not use a user id, then just return the same class
mixin TableEntry<T> {
  abstract int? id;

  Map<String, dynamic> toJson();

  TableEntry<T> addUserId(String userId);
}

/// Mixin for a table id
mixin HasId {
  int? get tableId;
}

/// Mixin for a user id
mixin HasUserId {
  String? get userId;
}

/// Mixin for a class that has a copyWith method
mixin hasCopyWith<T> {
  T get copyWith;
}

/// Definition of a function that takes data and returns a TableEntry class
typedef TableEntryCreator<T> = TableEntry<T> Function(T data);
