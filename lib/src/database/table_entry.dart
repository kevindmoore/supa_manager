
enum SelectType {
  and,
  or
}
class SelectEntry {
  final String columnName;
  final String value;
  final SelectType type;

  SelectEntry(this.columnName, this.value, this.type);

  SelectEntry.and(String columnName, String value): this(columnName, value, SelectType.and);
  SelectEntry.or(String columnName, String value): this(columnName, value, SelectType.or);
}

abstract class TableData<T> {
  late String tableName;
  T fromJson(Map<String, dynamic> json);
}

abstract class TableEntry<T> {
  abstract int? id;
  Map<String, dynamic> toJson();
  List<Map<String, dynamic>> addUserId(String userId);
}