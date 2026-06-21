import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supa_manager/supa_manager.dart';

import 'router/routes.dart';
import 'secret.dart';
import 'ui/utils.dart';

late Configuration configuration;
final configurationProvider = Provider<Configuration>((ref) {
  return configuration;
});

final logInStateProvider = Provider.family<LoginStateNotifier, Configuration>((
  ref,
  configuration,
) {
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
  final secrets = await SecretLoader(secretPath: 'assets/secrets.json').load();
  configuration = Configuration();
  await configuration.initialize(secrets.url, secrets.apiKey, null);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  var initialized = false;

  @override
  Widget build(BuildContext context) {
    // Do this once so that we automatically load in an existing user
    // This is not required
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: endGradientColor,
          primary: endGradientColor,
          secondary: actionColor,
          surface: cardBackgroundColor,
        ),
        scaffoldBackgroundColor: appBackgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: endGradientColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: cardBackgroundColor,
          surfaceTintColor: Colors.transparent,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
