import 'package:supabase_flutter/supabase_flutter.dart';

import 'result.dart';

class SignedOutException implements Exception {
  @override
  String toString() => 'SignedOutException';
}

class AuthTemporarilyUnavailableException implements Exception {
  final Object error;

  AuthTemporarilyUnavailableException(this.error);

  @override
  String toString() => 'AuthTemporarilyUnavailableException: $error';
}

class DatabaseTemporarilyUnavailableException implements Exception {
  final Object error;

  DatabaseTemporarilyUnavailableException(this.error);

  @override
  String toString() => 'DatabaseTemporarilyUnavailableException: $error';
}

/// Parses authentication errors and exceptions into clean, user-friendly messages.
String parseAuthError(Object error, {String fallback = 'Problems logging in'}) {
  if (error is AuthTemporarilyUnavailableException) {
    return 'Authentication service is temporarily unavailable. Please try again later.';
  }
  if (error is AuthException) {
    final message = error.message.trim();
    if (message.isNotEmpty) {
      final lower = message.toLowerCase();
      if (lower.contains('invalid login credentials') ||
          lower.contains('invalid credentials') ||
          lower.contains('invalid email or password')) {
        return 'Problems logging in: Invalid email or password.';
      }
      if (lower.contains('user already registered') ||
          lower.contains('already registered') ||
          lower.contains('user already exists')) {
        return 'An account with this email already exists.';
      }
      if (lower.contains('email not confirmed')) {
        return 'Email not confirmed. Please check your email for a confirmation link.';
      }
      if (lower.contains('rate limit') || lower.contains('too many requests')) {
        return 'Too many requests. Please wait a few minutes and try again.';
      }
      return message;
    }
    return fallback;
  }

  final errorStr = error.toString();
  if (errorStr.contains('SocketException') ||
      errorStr.contains('ClientException') ||
      errorStr.contains('NetworkError') ||
      errorStr.contains('Failed host lookup') ||
      errorStr.contains('Connection refused') ||
      errorStr.contains('XMLHttpRequest error')) {
    return 'Network error. Please check your internet connection.';
  }

  final messageMatch = RegExp(r'message:\s*([^,\)]+)').firstMatch(errorStr);
  if (messageMatch != null) {
    final extracted = messageMatch.group(1)?.trim();
    if (extracted != null && extracted.isNotEmpty) {
      final lower = extracted.toLowerCase();
      if (lower.contains('invalid login credentials') ||
          lower.contains('invalid credentials') ||
          lower.contains('invalid email or password')) {
        return 'Problems logging in: Invalid email or password.';
      }
      if (lower.contains('user already registered') ||
          lower.contains('already registered') ||
          lower.contains('user already exists')) {
        return 'An account with this email already exists.';
      }
      if (lower.contains('email not confirmed')) {
        return 'Email not confirmed. Please check your email for a confirmation link.';
      }
      return extracted;
    }
  }

  if (errorStr.startsWith('Exception: ')) {
    final clean = errorStr.substring('Exception: '.length).trim();
    if (clean.isNotEmpty) {
      return clean;
    }
  }

  return fallback;
}

extension ResultAuthErrorExtension<T> on Result<T> {
  String? errorMessageFormatted({String fallback = 'Problems logging in'}) {
    return switch (this) {
      Success() => null,
      Failure(error: final error) => parseAuthError(error, fallback: fallback),
      ErrorMessage(message: final message) =>
        message != null && message.trim().isNotEmpty ? message.trim() : fallback,
    };
  }
}
