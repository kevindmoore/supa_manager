
import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// Simple Result class with success, failure and errorMessage states.
@freezed
sealed class Result<T> with _$Result {
  const factory Result.success(T data) = Success;
  const factory Result.failure(Exception error) = Failure;
  const factory Result.errorMessage(int code, String? message) = ErrorMessage;
}