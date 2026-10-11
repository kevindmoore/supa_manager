import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lumberdash/lumberdash.dart';

import 'database_user.dart';
import 'errors.dart';
import 'login_state.dart';
import 'result.dart';

const String loggedInKey = 'LoggedIn';
const String userKey = 'user';
const String sessionKey = 'sessionKey';

class AuthListener {
  final Function(AuthState event) onData;
  final Function? onError;
  final void Function()? onDone;

  AuthListener({required this.onData, this.onError, this.onDone});
}

/// Class for handling Supabase Authorization
///
/// [apiKey] are required to use this class
/// [prefs] is needed for storing login informat
/// [loginStateNotifier] is needed for notifying users of login state changes
class SupaAuthManager {
  final String apiKey;
  final String? emailRedirectUrl;

  SupabaseClient client;
  final SharedPreferences prefs;
  final LoginStateNotifier? loginStateNotifier;
  StreamSubscription<AuthState>? _authSubscription;
  final _loggedInStateController = StreamController<bool>.broadcast();
  AuthTemporarilyUnavailableException? _temporaryAuthException;

  /// A stream that emits `true` when the user is logged in and `false` otherwise.
  /// This is the stream that the rest of the app should listen to.
  Stream<bool> get onLoginStateChange => _loggedInStateController.stream;

  bool get isAuthTemporarilyUnavailable => _temporaryAuthException != null;

  Exception authenticationFailure() {
    return _temporaryAuthException ?? SignedOutException();
  }

  SupaAuthManager({
    required this.client,
    required this.prefs,
    required this.apiKey,
    required this.loginStateNotifier,
    this.emailRedirectUrl,
  }) {
    // Initially we are not logged in
    _loggedInStateController.add(false);
  }

  /// When an app starts, call this to load any already logged in user
  Future<DatabaseUser?> loadUser() async {
    if (client.auth.currentUser != null) {
      final user = getUser();
      loginStateNotifier?.update(true, user);
      logMessage('loadUser: User exists, logged in');
      return user;
    }
    final recovered = await _recoverSession();
    if (!recovered) {
      final user = getUser();
      if (user != null &&
          user.email.isNotEmpty &&
          true == user.password?.isNotEmpty) {
        // Notifier is updated in this method
        logMessage('loadUser: User exists in session, logging in');
        await login(user.email, user.password!);
        return user;
      } else {
        loginStateNotifier?.loggedIn(false);
        _loggedInStateController.add(false);
        return null;
      }
    }
    loginStateNotifier?.loggedIn(false);
    loginStateNotifier?.update(false, null);
    return null;
  }

  /// Are we logged in?
  bool isLoggedIn() {
    if (client.auth.currentUser == null) {
      _updateLogoutState();
      return false;
    }
    if (client.auth.currentSession == null) {
      _updateLogoutState();
      return false;
    }
    return prefs.getBool(loggedInKey) ?? false;
  }

  /// Get the stored user information
  DatabaseUser? getUser() {
    final userString = prefs.getString(userKey);
    if (userString != null) {
      return DatabaseUser.fromJson(jsonDecode(userString));
    }
    return null;
  }

  /// Get the stored user email
  String? getUserEmail() {
    final user = getUser();
    return user?.email;
  }

  /// Get the stored user password
  String? getUserPassword() {
    final user = getUser();
    return user?.password;
  }

  /// Get the current logged in user
  DatabaseUser? getUserFromAuth() {
    final user = client.auth.currentUser;
    if (user == null) {
      return null;
    }
    return DatabaseUser(email: user.email!, userId: user.id);
  }

  void _authChanged(AuthState state) {
    switch (state.event) {
      case AuthChangeEvent.passwordRecovery:
        // TODO: Handle this case.
        break;
      case AuthChangeEvent.signedOut:
        _logoutState();
        _loggedInStateController.add(false);
        break;
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.userUpdated:
        _temporaryAuthException = null;
        loginStateNotifier?.loggedIn(true);
        if (state.session != null) {
          _saveUserSession(state.session!);
          _loggedInStateController.add(true);
        }
        break;
      case AuthChangeEvent.mfaChallengeVerified:
        break;
      case AuthChangeEvent.initialSession:
        break;
      // ignore: deprecated_member_use
      case AuthChangeEvent.userDeleted:
        _loggedInStateController.add(false);
        break;
    }
  }

  void _saveUserData(DatabaseUser? user, bool loggedIn) {
    if (user != null) {
      prefs.setString(userKey, jsonEncode(user));
    } else {
      prefs.remove(userKey);
    }
    prefs.setBool(loggedInKey, loggedIn);
  }

  /// Create a new user
  ///
  /// [email] email to use
  /// [password] password to use
  ///
  Future<Result<bool>> createUser(String email, String password) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: emailRedirectUrl,
      );
      if (response.session != null) {
        _saveUserSession(response.session!);
        final user = DatabaseUser(email: email, password: password);
        loginStateNotifier?.update(true, user);
        _saveUserData(user, true);
        _registerAuthListener();
        return const Result.success(true);
      } else if (response.user != null) {
        final user = DatabaseUser(email: email, password: password);
        loginStateNotifier?.update(true, user);
        _saveUserData(user, true);
        _registerAuthListener();
        return const Result.success(true);
      }
    } on Exception catch (error) {
      logError(error);
      return Result.failure(_authOperationFailure(error));
    }
    return const Result.success(false);
  }

  /// Delete the current user. WARNING: This will delete the current user
  Future<Result<bool>> deleteCurrentUser() async {
    try {
      await client.auth.admin.deleteUser(client.auth.currentUser!.id);
      return const Result.success(true);
    } on Exception catch (error) {
      logError(error);
      return Result.failure(error);
    }
  }

  /// Login an existing user
  ///
  /// [email] email to use
  /// [password] password to use
  Future<Result<DatabaseUser>> login(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        final user = DatabaseUser(
          email: email,
          password: password,
          userId: response.user?.id,
        );
        _saveUserSession(response.session!);
        _saveUserData(user, true);
        // This needs to be after saving state
        loginStateNotifier?.update(true, user);
        logMessage('login: User exists, logged in');
        _registerAuthListener();
        _loggedInStateController.add(true);
        return Result.success(user);
      }
    } on Exception catch (error) {
      logError(error);
      _loggedInStateController.add(false);
      loginStateNotifier?.loggedIn(false);
      return Result.failure(_authOperationFailure(error));
    }
    return const Result.errorMessage(99, 'Problems logging in');
  }

  /// Login with a third-party OAuth provider.
  ///
  /// [nativeRedirectUrl] is used for native app callbacks. On web, Supabase
  /// needs an HTTP(S) callback URL, so this defaults to the current page URL.
  Future<bool> loginWithOAuth(
    OAuthProvider provider, {
    String? nativeRedirectUrl,
    String? webRedirectUrl,
    String? scopes,
    LaunchMode authScreenLaunchMode = LaunchMode.externalApplication,
    Map<String, String>? queryParams,
  }) async {
    final redirectTo = kIsWeb ? webRedirectUrl ?? _currentWebRedirectUrl() : nativeRedirectUrl;
    if (kIsWeb && redirectTo == null) {
      throw ArgumentError('Web OAuth requires an HTTP(S) redirect URL.');
    }
    final launched = await client.auth.signInWithOAuth(
      provider,
      redirectTo: redirectTo,
      scopes: scopes,
      authScreenLaunchMode: kIsWeb ? LaunchMode.platformDefault : authScreenLaunchMode,
      queryParams: queryParams,
    );
    if (launched) {
      _registerAuthListener();
    }
    return launched;
  }

  String? _currentWebRedirectUrl() {
    final uri = Uri.base;
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return null;
    }
    return '${uri.scheme}://${uri.authority}/';
  }

  void _registerAuthListener() {
    if (_authSubscription != null) {
     return;
    }
    _authSubscription = client.auth.onAuthStateChange.listen((state) {
      _authChanged(state);
    });
  }

  /// Logout the current user
  void logout() async {
    try {
      _authSubscription?.cancel();
      await client.auth.signOut();
    } catch (e) {
      logError(e);
    }
    _logoutState();
  }

  void _updateLogoutState() {
    if (prefs.getBool(loggedInKey) ?? false) {
      _logoutState();
    }
  }

  void _logoutState() {
    _temporaryAuthException = null;
    _loggedInStateController.add(false);
    prefs.setBool(loggedInKey, false);
    _clearUserSession();
    loginStateNotifier?.update(false, null);
  }

  void _saveUserSession(Session session) async {
    await prefs.setString(sessionKey, getPersistSessionString(session));
    // await prefs.setString(sessionKey, session.persistSessionString);
  }

  String getPersistSessionString(Session session) {
    final data = {
      'currentSession': session.toJson(),
      'expiresAt': session.expiresAt,
    };
    return json.encode(data);
  }

  void _clearUserSession() async {
    await prefs.remove(sessionKey);
    prefs.remove(userKey);
  }

  Future<bool> _recoverSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(sessionKey)) {
      try {
        final jsonStr = prefs.getString(sessionKey)!;
        final response = await client.auth.recoverSession(jsonStr);
        if (response.session != null && response.session?.isExpired == false) {
          final builder =
              DatabaseUserBuilder()
                ..email(response.user?.email)
                ..userId(response.user?.id);
          final user = builder.build();
          loginStateNotifier?.update(true, user);
          _saveUserSession(response.session!);
          _saveUserData(user, true);
          return true;
        }
      } catch (error) {
        if (_isMissingSessionError(error)) {
          logError('Problems recovering session $error');
          _logoutState();
          return false;
        }
        if (_handleTemporaryAuthFailure(error)) {
          logWarning('Auth temporarily unavailable while recovering session: $error');
          return false;
        }
        logError('Problems recovering session $error');
      }
    }
    return false;
  }

  /// Refresh the current session
  Future<bool> refreshSession() async {
    try {
      final response = await client.auth.refreshSession();
      if (response.session != null) {
        _temporaryAuthException = null;
        _saveUserSession(response.session!);
      }
      return true;
    } catch (e) {
      if (_handleTemporaryAuthFailure(e)) {
        logWarning('Auth temporarily unavailable while refreshing session: $e');
      } else {
        _logoutState();
        logFatal('Problems refreshing session: $e');
      }
    }
    return false;
  }

  bool _handleTemporaryAuthFailure(Object error) {
    if (error is! AuthRetryableFetchException) return false;
    _temporaryAuthException = AuthTemporarilyUnavailableException(error);
    return true;
  }

  Exception _authOperationFailure(Exception error) {
    if (error is AuthRetryableFetchException) {
      return AuthTemporarilyUnavailableException(error);
    }
    return error;
  }

  bool _isMissingSessionError(Object error) {
    return error is AuthException && error.code == 'session_missing';
  }

  /// Reset the password for the given email
  /// [email] email to reset
  Future<Result<bool>> resetPassword(String email, [String? redirect]) async {
    try {
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: redirect ?? emailRedirectUrl,
      );
      return const Result.success(true);
    } on Exception catch (error) {
      logFatal('Problems resetting password: $error');
      return Result.failure(_authOperationFailure(error));
    }
  }

  /// Update user's password
  /// TODO: Not sure if this is working correctly
  Future<User?> updateUserPassword(String email, String password) async {
    try {
      final response = await client.auth.updateUser(
        UserAttributes(email: email, password: password),
      );
      return response.user;
    } catch (error) {
      logFatal('Problems resetting password: $error');
      return null;
    }
  }
}
