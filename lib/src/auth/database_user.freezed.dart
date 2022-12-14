// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'database_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DatabaseUser _$DatabaseUserFromJson(Map<String, dynamic> json) {
  return _DatabaseUser.fromJson(json);
}

/// @nodoc
mixin _$DatabaseUser {
  String? get sessionId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DatabaseUserCopyWith<DatabaseUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DatabaseUserCopyWith<$Res> {
  factory $DatabaseUserCopyWith(
          DatabaseUser value, $Res Function(DatabaseUser) then) =
      _$DatabaseUserCopyWithImpl<$Res>;
  $Res call(
      {String? sessionId,
      String email,
      String? password,
      String? name,
      String? userId});
}

/// @nodoc
class _$DatabaseUserCopyWithImpl<$Res> implements $DatabaseUserCopyWith<$Res> {
  _$DatabaseUserCopyWithImpl(this._value, this._then);

  final DatabaseUser _value;
  // ignore: unused_field
  final $Res Function(DatabaseUser) _then;

  @override
  $Res call({
    Object? sessionId = freezed,
    Object? email = freezed,
    Object? password = freezed,
    Object? name = freezed,
    Object? userId = freezed,
  }) {
    return _then(_value.copyWith(
      sessionId: sessionId == freezed
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      email: email == freezed
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: password == freezed
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: userId == freezed
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$$_DatabaseUserCopyWith<$Res>
    implements $DatabaseUserCopyWith<$Res> {
  factory _$$_DatabaseUserCopyWith(
          _$_DatabaseUser value, $Res Function(_$_DatabaseUser) then) =
      __$$_DatabaseUserCopyWithImpl<$Res>;
  @override
  $Res call(
      {String? sessionId,
      String email,
      String? password,
      String? name,
      String? userId});
}

/// @nodoc
class __$$_DatabaseUserCopyWithImpl<$Res>
    extends _$DatabaseUserCopyWithImpl<$Res>
    implements _$$_DatabaseUserCopyWith<$Res> {
  __$$_DatabaseUserCopyWithImpl(
      _$_DatabaseUser _value, $Res Function(_$_DatabaseUser) _then)
      : super(_value, (v) => _then(v as _$_DatabaseUser));

  @override
  _$_DatabaseUser get _value => super._value as _$_DatabaseUser;

  @override
  $Res call({
    Object? sessionId = freezed,
    Object? email = freezed,
    Object? password = freezed,
    Object? name = freezed,
    Object? userId = freezed,
  }) {
    return _then(_$_DatabaseUser(
      sessionId: sessionId == freezed
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      email: email == freezed
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: password == freezed
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: userId == freezed
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_DatabaseUser implements _DatabaseUser {
  const _$_DatabaseUser(
      {this.sessionId,
      required this.email,
      this.password,
      this.name,
      this.userId});

  factory _$_DatabaseUser.fromJson(Map<String, dynamic> json) =>
      _$$_DatabaseUserFromJson(json);

  @override
  final String? sessionId;
  @override
  final String email;
  @override
  final String? password;
  @override
  final String? name;
  @override
  final String? userId;

  @override
  String toString() {
    return 'DatabaseUser(sessionId: $sessionId, email: $email, password: $password, name: $name, userId: $userId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DatabaseUser &&
            const DeepCollectionEquality().equals(other.sessionId, sessionId) &&
            const DeepCollectionEquality().equals(other.email, email) &&
            const DeepCollectionEquality().equals(other.password, password) &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.userId, userId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(sessionId),
      const DeepCollectionEquality().hash(email),
      const DeepCollectionEquality().hash(password),
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(userId));

  @JsonKey(ignore: true)
  @override
  _$$_DatabaseUserCopyWith<_$_DatabaseUser> get copyWith =>
      __$$_DatabaseUserCopyWithImpl<_$_DatabaseUser>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DatabaseUserToJson(
      this,
    );
  }
}

abstract class _DatabaseUser implements DatabaseUser {
  const factory _DatabaseUser(
      {final String? sessionId,
      required final String email,
      final String? password,
      final String? name,
      final String? userId}) = _$_DatabaseUser;

  factory _DatabaseUser.fromJson(Map<String, dynamic> json) =
      _$_DatabaseUser.fromJson;

  @override
  String? get sessionId;
  @override
  String get email;
  @override
  String? get password;
  @override
  String? get name;
  @override
  String? get userId;
  @override
  @JsonKey(ignore: true)
  _$$_DatabaseUserCopyWith<_$_DatabaseUser> get copyWith =>
      throw _privateConstructorUsedError;
}
