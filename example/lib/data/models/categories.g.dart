// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
      name: json['name'] as String,
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String?,
    );

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
      'name': instance.name,
      if (instance.id case final value?) 'id': value,
      if (instance.userId case final value?) 'user_id': value,
    };
