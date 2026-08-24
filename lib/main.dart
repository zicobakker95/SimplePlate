import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'screens/home/home_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/ad_config.dart';
import 'services/ad_service.dart';
import 'services/analytics_service.dart';
import 'services/food_store.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/subscription_service.dart';
import 'services/widget_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase: analytics (UA/marketing) + crash reporting. Wrapped so a
  // Firebase init failure never prevents the app from launching — a missing
  // or bad config should cost us reporting, not the whole app.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  final storage = await StorageService.init();
  await NotificationService.instance.init();
  // Ad frequency comes from Remote Config so it can be tuned and A/B tested
  // without a build. Fire-and-forget: it activates whatever was fetched last
  // launch and refreshes in the background, falling back to the shipped
  // defaults until one arrives. Startup never waits on the network.
  unawaited(AdConfig.instance.init());
  await AdService.instance.initialize();
  await WidgetService.instance.init();
  // Subscriptions are initialized in parallel; don't await to keep startup fast
  SubscriptionService.instance.initialize();
  runApp(SimplePlateApp(storage: storage));
}

class SimplePlateApp extends StatelessWidget {
  const SimplePlateApp({super.key, required this.storage});
  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FoodStore(storage),
      child: MaterialApp(
        title: 'PlateSimple',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Null when Firebase is unavailable — the app still runs, it just
        // stops reporting screen views.
        navigatorObservers: [
          ?AnalyticsService.instance.observer,
        ],
        home: storage.onboardingDone
            ? const HomeShell()
            : const OnboardingScreen(),
      ),
    );
  }
}
