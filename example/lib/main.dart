import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supa_manager/supa_manager.dart';

import 'router/routes.dart';
import 'secret.dart';

late Configuration configuration;
final configurationProvider = Provider<Configuration>((ref) {
  return configuration;
});
final logInStateProvider =
Provider.family<LoginStateNotifier, Configuration>((ref, configuration) {
  return configuration.loginStateNotifier;
});

final supaBaseDatabaseProvider =
Provider.family<SupaDatabaseManager, Configuration>((ref, configuration) {
  return configuration.supaDatabaseRepository;
});


LoginStateNotifier getLoginStateNotifier(Ref ref) {
  return ref.read(configurationProvider).loginStateNotifier;
}

SupaDatabaseManager getSupaDatabaseManager(Ref ref) {
  return ref.read(configurationProvider).supaDatabaseRepository;
}

SupaAuthManager getSupaAuthManager(WidgetRef ref) {
  return ref.read(configurationProvider).supaAuthManager;
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final container = ProviderContainer();
  // globalSharedPreferences = await SharedPreferences.getInstance();
  globalSecrets = await SecretLoader(secretPath: 'assets/secrets.json').load();
  configuration = Configuration();
  await configuration.initialize(globalSecrets.url, globalSecrets.apiKey, globalSecrets.apiSecret);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  var initialized = false;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (initialized) {
        return;
      }
      final auth = getSupaAuthManager(ref);
      auth.loadUser();
      initialized = true;
    });
    final router = ref.watch(routeProvider).router;
    return MaterialApp.router(
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      debugShowCheckedModeBanner: false,
      title: 'Today',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }

}