import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supa_manager/supa_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('parseAuthError', () {
    test('formats invalid login credentials AuthException nicely', () {
      const error = AuthException('Invalid login credentials', statusCode: '400');
      final message = parseAuthError(error);
      expect(message, 'Problems logging in: Invalid email or password.');
    });

    test('formats already registered AuthException nicely', () {
      const error = AuthException('User already registered');
      final message = parseAuthError(error);
      expect(message, 'An account with this email already exists.');
    });

    test('formats email not confirmed AuthException nicely', () {
      const error = AuthException('Email not confirmed');
      final message = parseAuthError(error);
      expect(message, 'Email not confirmed. Please check your email for a confirmation link.');
    });

    test('formats rate limit AuthException nicely', () {
      const error = AuthException('Email rate limit exceeded');
      final message = parseAuthError(error);
      expect(message, 'Too many requests. Please wait a few minutes and try again.');
    });

    test('passes through specific AuthException messages cleanly', () {
      const error = AuthException('Password should be at least 6 characters');
      final message = parseAuthError(error);
      expect(message, 'Password should be at least 6 characters');
    });

    test('formats AuthTemporarilyUnavailableException', () {
      final error = AuthTemporarilyUnavailableException('Server down');
      final message = parseAuthError(error);
      expect(message, 'Authentication service is temporarily unavailable. Please try again later.');
    });

    test('formats SocketException / network errors', () {
      const error = SocketException('Failed host lookup: example.supabase.co');
      final message = parseAuthError(error);
      expect(message, 'Network error. Please check your internet connection.');
    });

    test('extracts message from string representation of exception', () {
      final error = Exception('AuthApiException(message: Invalid login credentials, statusCode: 400)');
      final message = parseAuthError(error);
      expect(message, 'Problems logging in: Invalid email or password.');
    });

    test('returns custom fallback when error message is unknown', () {
      final error = Exception('Some unknown internal error');
      final message = parseAuthError(error, fallback: 'Problems logging in');
      expect(message, 'Some unknown internal error');
    });
  });

  group('ResultAuthErrorExtension', () {
    test('returns null for Success', () {
      const result = Result<String>.success('ok');
      expect(result.errorMessageFormatted(), isNull);
    });

    test('formats Failure error message', () {
      const result = Result<String>.failure(
        AuthException('Invalid login credentials', statusCode: '400'),
      );
      expect(result.errorMessageFormatted(), 'Problems logging in: Invalid email or password.');
    });

    test('formats ErrorMessage', () {
      const result = Result<String>.errorMessage(99, 'Problems logging in');
      expect(result.errorMessageFormatted(), 'Problems logging in');
    });
  });
}
