import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../core/services/ad_service.dart';
import '../core/services/logger_service.dart';
import '../core/storage/local_storage.dart' as core_storage;

/// Initializes app services before rendering the first frame.
Future<void> bootstrap() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration from the bundled .env asset.
  // This must run before any service (Supabase, etc.) is initialized so that
  // production credentials are available on every platform (Android, iOS, Web).
  await dotenv.load(fileName: '.env');

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase (mobile only — Firebase is not configured for web)
  if (!kIsWeb) {
    await Firebase.initializeApp();
    Logger.info('Firebase initialized');

    // Configure Firebase Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    Logger.info('Crashlytics configured');

    // Initialize Firebase Analytics
    FirebaseAnalytics.instance;
    Logger.info('Analytics initialized');
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    Logger.info('Supabase initialized');
  } catch (e) {
    Logger.info('Supabase init error: $e');
    rethrow;
  }

  // Initialize local storage
  await core_storage.LocalStorage.init();
  Logger.info('Local storage initialized');

  // Initialize RevenueCat (mobile only — no web implementation)
  if (!kIsWeb) {
    await Purchases.setDebugLogsEnabled(kDebugMode);
    await Purchases.configure(
      PurchasesConfiguration(AppConstants.revenueCatApiKey),
    );
    Logger.info('RevenueCat initialized');
  }

  // Initialize Google Mobile Ads (pre-loads rewarded ads)
  await AdService.instance.initialize();
  Logger.info('AdMob initialized');

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}
