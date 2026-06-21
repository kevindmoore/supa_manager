import 'package:freezed_annotation/freezed_annotation.dart';

part 'tasks.freezed.dart';
part 'tasks.g.dart';

List<Map<String, dynamic>> taskToDatabaseJson(Task task, String userId) {
  final todoFiles = <Map<String, dynamic>>[];
  final updatedTodoFile = task.copyWith(userId: userId);
  todoFiles.add(updatedTodoFile.toJson());
  return todoFiles;
}

@freezed
abstract class Task with _$Task {
  factory Task({
    required String name,
    @JsonKey(includeIfNull: false) int? id,
    @JsonKey(name: 'user_id', includeIfNull: false) String? userId,
    @Default(false) bool done,
    @JsonKey(name: 'do_later') @Default(false) bool doLater,
    @JsonKey(name: 'category_id', includeIfNull: false) int? categoryId,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
