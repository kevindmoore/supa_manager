import 'package:lumberdash/lumberdash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supa_manager/supa_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


/// In order to initialize the database you need the following:
/// * The url to your supabase instance. This will be in the format of https://<some long set of characters>.supabase.co
/// * The Api Key. This will be a very, very long string of characters from the supabase website
/// * The Api Secret. This will be a very, very long string of characters from the supabase website
/// Make sure you call initialize or supaBaseAuthProvider will fail. Do this in your main function
/// SecretLoader is in the example package
/// ```code
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   // Initialize Supabase Auth
///   final secrets = await SecretLoader(secretPath: 'assets/secrets.json').load();
///   configuration = Configuration();
///   await configuration.initialize(
///     secrets.url, secrets.apiKey, secrets.apiSecret);
///   runApp(child: const MyApp());
/// }
/// ```
///
class Configuration {
  late Supabase supabaseInstance;
  late SupaAuthManager supaAuthManager;
  late SupaDatabaseManager supaDatabaseRepository;
  late SharedPreferences globalSharedPreferences;
  final loginStateNotifier = LoginStateNotifier();

  Future initialize(String url,
      String apiKey, String apiSecret) async {
    try {
      supabaseInstance = await Supabase.initialize(
        url: url,
        anonKey: apiKey,
        debug: false,
      );
    } on Exception catch (error) {
      logError(error);
    }
    globalSharedPreferences = await SharedPreferences.getInstance();
    supaAuthManager = SupaAuthManager(
        client: supabaseInstance.client,
        prefs: globalSharedPreferences,
        apiKey: apiKey,
        apiSecret: apiSecret,
        loginStateNotifier: loginStateNotifier);
    supaDatabaseRepository = SupaDatabaseManager(supaAuthManager, Supabase.instance.client);
  }
}
