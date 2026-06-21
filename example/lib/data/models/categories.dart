import 'package:freezed_annotation/freezed_annotation.dart';

part 'categories.freezed.dart';
part 'categories.g.dart';

List<Map<String, dynamic>> categoryToDatabaseJson(
    Category category, String userId) {
  final categories = <Map<String, dynamic>>[];
  final updatedCategory = category.copyWith(userId: userId);
  categories.add(updatedCategory.toJson());
  return categories;
}

@freezed
abstract class Category with _$Category {
  factory Category({
    required String name,
    @JsonKey(includeIfNull: false) int? id,
    @JsonKey(name: 'user_id', includeIfNull: false) String? userId,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
