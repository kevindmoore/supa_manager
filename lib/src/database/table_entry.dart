abstract class TableData<T> {
  late String tableName;

  T fromJson(Map<String, dynamic> json);
}

mixin TableEntry<T> {
  abstract int? id;

  Map<String, dynamic> toJson();

  T addUserId(String userId);
}

mixin HasId {
  int? get tableId;
}

mixin HasUserId {
  String? get userId;
}

mixin hasCopyWith<T> {
  T get copyWith;
}

typedef TableEntryCreator<T> = TableEntry<T> Function(T data);
