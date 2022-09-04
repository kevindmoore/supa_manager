import 'package:freezed_annotation/freezed_annotation.dart';

part 'database_user.freezed.dart';
part 'database_user.g.dart';

@freezed
class DatabaseUser with _$DatabaseUser {
  @JsonSerializable(explicitToJson: true)
  const factory DatabaseUser({
    String? sessionId,
    required String email,
    String? password,
    String? name,
    String? userId
  }
  ) = _DatabaseUser;
  factory DatabaseUser.fromJson(Map<String, dynamic> json) =>
      _$DatabaseUserFromJson(json);

}

class DatabaseUserBuilder {
  String? _sessionId;
  String? _email;
  String? _password;
  String? _name;
  String? _userId;

  DatabaseUserBuilder email(String? email) {
    if (email != null) {
      _email = email;
    }
    return this;
  }

  DatabaseUserBuilder sessionId(String? sessionId) {
    if (sessionId != null) {
      _sessionId = sessionId;
    }
    return this;
  }

  DatabaseUserBuilder password(String? password) {
    if (password != null) {
      _password = password;
    }
    return this;
  }

  DatabaseUserBuilder name(String? name) {
    if (name != null) {
      _name = name;
    }
    return this;
  }

  DatabaseUserBuilder userId(String? userId) {
    if (userId != null) {
      _userId = userId;
    }
    return this;
  }

  DatabaseUser build() {
    assert(_email != null);
    var user = DatabaseUser(email: _email!, password: _password);
    if (_sessionId != null) {
      user = user.copyWith(sessionId: _sessionId);
    }
    if (_name != null) {
      user = user.copyWith(name: _name);
    }
    if (_userId != null) {
      user = user.copyWith(userId: _userId);
    }
    return user;
  }
}