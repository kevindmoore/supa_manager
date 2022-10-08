/// Two different seleciton types: And and Or
enum SelectType {
  and,
  or
}

/// Describe a selection
///
/// [columnName] The name of the column
///
/// [value] The value of the column
///
/// [type] The type of the column
class SelectEntry {
  final String columnName;
  final String value;
  final SelectType type;

  SelectEntry(this.columnName, this.value, this.type);

  SelectEntry.and(String columnName, String value): this(columnName, value, SelectType.and);
  SelectEntry.or(String columnName, String value): this(columnName, value, SelectType.or);
}
