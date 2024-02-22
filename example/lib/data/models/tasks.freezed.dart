// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tasks.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Task _$TaskFromJson(Map<String, dynamic> json) {
  return _Task.fromJson(json);
}

/// @nodoc
mixin _$Task {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  String? get userId => throw _privateConstructorUsedError;
  bool get done => throw _privateConstructorUsedError;
  bool get doLater => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  int? get categoryId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TaskCopyWith<Task> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCopyWith<$Res> {
  factory $TaskCopyWith(Task value, $Res Function(Task) then) =
      _$TaskCopyWithImpl<$Res, Task>;
  @useResult
  $Res call(
      {String name,
      @JsonKey(includeIfNull: false) int? id,
      @JsonKey(includeIfNull: false) String? userId,
      bool done,
      bool doLater,
      @JsonKey(includeIfNull: false) int? categoryId});
}

/// @nodoc
class _$TaskCopyWithImpl<$Res, $Val extends Task>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? id = freezed,
    Object? userId = freezed,
    Object? done = null,
    Object? doLater = null,
    Object? categoryId = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      done: null == done
          ? _value.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      doLater: null == doLater
          ? _value.doLater
          : doLater // ignore: cast_nullable_to_non_nullable
              as bool,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskImplCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$$TaskImplCopyWith(
          _$TaskImpl value, $Res Function(_$TaskImpl) then) =
      __$$TaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      @JsonKey(includeIfNull: false) int? id,
      @JsonKey(includeIfNull: false) String? userId,
      bool done,
      bool doLater,
      @JsonKey(includeIfNull: false) int? categoryId});
}

/// @nodoc
class __$$TaskImplCopyWithImpl<$Res>
    extends _$TaskCopyWithImpl<$Res, _$TaskImpl>
    implements _$$TaskImplCopyWith<$Res> {
  __$$TaskImplCopyWithImpl(_$TaskImpl _value, $Res Function(_$TaskImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? id = freezed,
    Object? userId = freezed,
    Object? done = null,
    Object? doLater = null,
    Object? categoryId = freezed,
  }) {
    return _then(_$TaskImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      done: null == done
          ? _value.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      doLater: null == doLater
          ? _value.doLater
          : doLater // ignore: cast_nullable_to_non_nullable
              as bool,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$TaskImpl implements _Task {
  _$TaskImpl(
      {required this.name,
      @JsonKey(includeIfNull: false) this.id,
      @JsonKey(includeIfNull: false) this.userId,
      this.done = false,
      this.doLater = false,
      @JsonKey(includeIfNull: false) this.categoryId});

  factory _$TaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(includeIfNull: false)
  final int? id;
  @override
  @JsonKey(includeIfNull: false)
  final String? userId;
  @override
  @JsonKey()
  final bool done;
  @override
  @JsonKey()
  final bool doLater;
  @override
  @JsonKey(includeIfNull: false)
  final int? categoryId;

  @override
  String toString() {
    return 'Task(name: $name, id: $id, userId: $userId, done: $done, doLater: $doLater, categoryId: $categoryId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.done, done) || other.done == done) &&
            (identical(other.doLater, doLater) || other.doLater == doLater) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, id, userId, done, doLater, categoryId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      __$$TaskImplCopyWithImpl<_$TaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskImplToJson(
      this,
    );
  }
}

abstract class _Task implements Task {
  factory _Task(
      {required final String name,
      @JsonKey(includeIfNull: false) final int? id,
      @JsonKey(includeIfNull: false) final String? userId,
      final bool done,
      final bool doLater,
      @JsonKey(includeIfNull: false) final int? categoryId}) = _$TaskImpl;

  factory _Task.fromJson(Map<String, dynamic> json) = _$TaskImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(includeIfNull: false)
  int? get id;
  @override
  @JsonKey(includeIfNull: false)
  String? get userId;
  @override
  bool get done;
  @override
  bool get doLater;
  @override
  @JsonKey(includeIfNull: false)
  int? get categoryId;
  @override
  @JsonKey(ignore: true)
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
