// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
      name: json['name'] as String,
      id: json['id'] as int?,
      userId: json['userId'] as String?,
      done: json['done'] as bool? ?? false,
      doLater: json['doLater'] as bool? ?? false,
      categoryId: json['categoryId'] as int?,
    );

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('userId', instance.userId);
  val['done'] = instance.done;
  val['doLater'] = instance.doLater;
  writeNotNull('categoryId', instance.categoryId);
  return val;
}
