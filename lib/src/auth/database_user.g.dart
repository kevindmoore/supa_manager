// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_DatabaseUser _$$_DatabaseUserFromJson(Map<String, dynamic> json) =>
    _$_DatabaseUser(
      sessionId: json['sessionId'] as String?,
      email: json['email'] as String,
      password: json['password'] as String?,
      name: json['name'] as String?,
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$$_DatabaseUserToJson(_$_DatabaseUser instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'email': instance.email,
      'password': instance.password,
      'name': instance.name,
      'userId': instance.userId,
    };
