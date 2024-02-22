import 'package:gotrue/gotrue.dart';

class AuthStorage extends GotrueAsyncStorage {
  final itemStore = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async {
    return itemStore[key];
  }

  @override
  Future<void> removeItem({required String key}) async {
    itemStore.remove(key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    itemStore[key] = value;
  }

}