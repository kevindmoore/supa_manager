import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lumberdash/lumberdash.dart';

import 'database_user.dart';
import 'login_state.dart';
import 'result.dart';

const String loggedInKey = 'LoggedIn';
const String userKey = 'user';
const String sessionKey = 'sessionKey';

/// Class for handling Supabase Authorization
///
/// [apiKey] and [apiSecret] are required to use this class
/// [prefs] is needed for storing login informat
/// [loginStateNotifier] is needed for notifying users of login state changes
class SupaAuthManager {
  final String apiKey;
  final String apiSecret;

  SupabaseClient client;
  final SharedPreferences prefs;
  final LoginStateNotifier? loginStateNotifier;

  SupaAuthManager(
      {required this.client,
      required this.prefs,
      required this.apiKey,
      required this.apiSecret,
      required this.loginStateNotifier});

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
        return null;
      }
    }
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
      case AuthChangeEvent.signedIn:
        loginStateNotifier?.loggedIn(true);
        if (state.session != null) {
          _saveUserSession(state.session!);
        }
        break;
      case AuthChangeEvent.signedOut:
        _logoutState();
        break;
      case AuthChangeEvent.tokenRefreshed:
        if (state.session != null) {
          _saveUserSession(state.session!);
        }
        break;
      case AuthChangeEvent.userUpdated:
        if (state.session != null) {
          _saveUserSession(state.session!);
        }
        break;
      case AuthChangeEvent.userDeleted:
        _logoutState();
        break;
      case AuthChangeEvent.mfaChallengeVerified:
        break;
      case AuthChangeEvent.initialSession:
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
      final response =
          await client.auth.signUp(email: email, password: password);
      if (response.session != null) {
        _saveUserSession(response.session!);
        final user = DatabaseUser(email: email, password: password);
        loginStateNotifier?.update(true, user);
        _saveUserData(user, true);
        _registerAuthListener();
        return const Result.success(true);
      }
    } on Exception catch (error) {
      logError(error);
      return Result.failure(error);
    }
    return const Result.success(false);
  }

  /// Login an existing user
  ///
  /// [email] email to use
  /// [password] password to use
  Future<Result<DatabaseUser>> login(String email, String password) async {
    try {
      final response = await client.auth
          .signInWithPassword(email: email, password: password);
      if (response.session != null) {
        final user = DatabaseUser(
            email: email, password: password, userId: response.user?.id);
        _saveUserSession(response.session!);
        _saveUserData(user, true);
        // This needs to be after saving state
        loginStateNotifier?.update(true, user);
        logMessage('login: User exists, logged in');
        _registerAuthListener();
        return Result.success(user);
      }
    } catch (e) {
      logError(e);
      loginStateNotifier?.loggedIn(false);
      return Result.errorMessage(99, e.toString());
    }
    return const Result.errorMessage(99, 'Problems logging in');
  }

  void _registerAuthListener() {
    client.auth.onAuthStateChange.listen((state) {
      _authChanged(state);
    });
  }

  /// Logout the current user
  void logout() async {
    _logoutState();
    try {
      await client.auth.signOut();
    } catch (e) {
      logError(e);
    }
  }

  void _updateLogoutState() {
    if (prefs.getBool(loggedInKey) ?? false) {
      _logoutState();
    }
  }

  void _logoutState() {
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
      'expiresAt': session.expiresAt
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
        final session = await client.auth.recoverSession(jsonStr);
        final builder = DatabaseUserBuilder()
          ..email(session.user?.email)
          ..userId(session.user?.id);
        final user = builder.build();
        loginStateNotifier?.update(true, user);
        _saveUserSession(session.session!);
        _saveUserData(user, true);
        return true;
      } catch (error) {
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
        _saveUserSession(response.session!);
      }
      return true;
    } catch (e) {
      logFatal('Problems refreshing session: $e');
    }
    return false;
  }

  /// Reset the password for the given email
  /// TODO: Not sure if this is working correctly
  /// [email] email to reset
  void resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(
        email,
        // redirectTo: 'io.supabase.flutter://reset-callback/',
      );
    } catch (error) {
      logFatal('Problems resetting password: $error');
    }
  }

  /// Update user's password
  /// TODO: Not sure if this is working correctly
  Future<User?> updateUserPassword(String email, String password) async {
    try {
      final response = await client.auth
          .updateUser(UserAttributes(email: email, password: password));
      return response.user;
    } catch (error) {
      logFatal('Problems resetting password: $error');
      return null;
    }
  }
}
