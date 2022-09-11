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
