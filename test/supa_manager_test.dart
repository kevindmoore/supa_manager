import 'package:flutter_test/flutter_test.dart';

import 'package:supa_manager/supa_manager.dart';

void main() {
  test('creates an anonymous database manager without auth state', () {
    final manager = SupaDatabaseManager.anonymous(
      'https://example.supabase.co',
      'test-publishable-key',
    );

    expect(manager.authManager, isNull);
  });
}
