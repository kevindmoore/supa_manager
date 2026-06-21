// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
      name: json['name'] as String,
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String?,
      done: json['done'] as bool? ?? false,
      doLater: json['do_later'] as bool? ?? false,
      categoryId: (json['category_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
      'name': instance.name,
      if (instance.id case final value?) 'id': value,
      if (instance.userId case final value?) 'user_id': value,
      'done': instance.done,
      'do_later': instance.doLater,
      if (instance.categoryId case final value?) 'category_id': value,
    };
