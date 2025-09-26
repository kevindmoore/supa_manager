// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DatabaseUser _$DatabaseUserFromJson(Map<String, dynamic> json) =>
    _DatabaseUser(
      sessionId: json['sessionId'] as String?,
      email: json['email'] as String,
      password: json['password'] as String?,
      name: json['name'] as String?,
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$DatabaseUserToJson(_DatabaseUser instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'email': instance.email,
      'password': instance.password,
      'name': instance.name,
      'userId': instance.userId,
    };
