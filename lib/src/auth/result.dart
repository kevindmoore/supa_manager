
import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// Simple Result class with success, failure and errorMessage states.
@freezed
class Result<T> with _$Result {
  const factory Result.success(T data) = _Success;
  const factory Result.failure(Exception error) = _Failure;
  const factory Result.errorMessage(int code, String? message) = _ErrorMessage;
}