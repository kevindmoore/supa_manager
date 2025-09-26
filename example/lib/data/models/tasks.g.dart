// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  name: json['name'] as String,
  id: (json['id'] as num?)?.toInt(),
  userId: json['userId'] as String?,
  done: json['done'] as bool? ?? false,
  doLater: json['doLater'] as bool? ?? false,
  categoryId: (json['categoryId'] as num?)?.toInt(),
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'name': instance.name,
  if (instance.id case final value?) 'id': value,
  if (instance.userId case final value?) 'userId': value,
  'done': instance.done,
  'doLater': instance.doLater,
  if (instance.categoryId case final value?) 'categoryId': value,
};
