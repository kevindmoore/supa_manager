import 'package:flutter/material.dart';

import 'database_user.dart';

/// Notifies listeners of changes in the login state
/// This needs to be a ChangeNotifier for GoRouter
class LoginStateNotifier extends ChangeNotifier {
  var state = LoginState(loggedIn: false, user: null);

  bool isLoggedIn() {
    return state.loggedIn;
  }
  void loggedIn(bool value) {
    if (state.loggedIn != value) {
      state = LoginState(loggedIn: value, user: state.user);
      notifyListeners();
    }
  }

  void user(DatabaseUser? newUser) {
    if (state.user != newUser) {
      state = LoginState(loggedIn: state.loggedIn, user: newUser);
      notifyListeners();
    }
  }

  void update(bool loggedIn, DatabaseUser? user) {
    if (state.loggedIn != loggedIn || state.user != user) {
      state = LoginState(loggedIn: loggedIn, user: user);
      notifyListeners();
    }
  }
}

/// Contains information on whether the user logged in and their user information
///
/// [loggedIn] Logged in state
///
/// [user] User information
class LoginState {
  final bool loggedIn;
  final DatabaseUser? user;

  LoginState({required this.loggedIn, this.user});
}
