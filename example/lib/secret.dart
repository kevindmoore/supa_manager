import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;

late Secrets globalSecrets;

class Secrets {
  final String url;
  final String apiKey;
  final String apiSecret;

  Secrets({required this.url, required this.apiKey, required this.apiSecret});

  factory Secrets.fromJson(Map<String, dynamic> jsonMap) {
    return Secrets(
        url: jsonMap['url'],
        apiKey: jsonMap['api_key'],
        apiSecret: jsonMap['api_secret']);
  }
}

class SecretLoader {
  final String secretPath;

  SecretLoader({required this.secretPath});

  Future<Secrets> load() {
    return rootBundle.loadStructuredData<Secrets>(secretPath, (jsonStr) async {
      final secret = Secrets.fromJson(json.decode(jsonStr));
      return secret;
    });
  }
}
