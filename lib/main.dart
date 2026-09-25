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
import 'services/health_sync_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/subscription_service.dart';
import 'services/widget_service.dart';
import 'theme/app_theme.dart';
import 'utils/crash_severity.dart';

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
      // Errors the app recovers from on its own — a dropped Open Food Facts
      // lookup, a Remote Config refresh that failed — are still reported, but
      // never as fatal. Recording them fatal is what took Deadlight's
      // crash-free users to 89.9%; see crash_severity.dart.
      FirebaseCrashlytics.instance
          .recordError(error, stack, fatal: !isRecoverableError(error));
      return true;
    };
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  final storage = await StorageService.init();
  // Everything below is optional at launch. Each step is guarded on its own so
  // one that throws on a device we have never seen (a fresh install, a store
  // that does not answer) costs that feature, never the first frame.
  await _startupStep('notifications', NotificationService.instance.init);
  // Health sync (Premium) re-checks its grant in the background so the first
  // food logged today is written without a prompt. Never awaited: a slow
  // Health Connect must not hold the first frame.
  if (storage.healthSyncEnabled) {
    unawaited(_startupStep('health sync', HealthSyncService.instance.restore));
  }
  // Ad frequency comes from Remote Config so it can be tuned and A/B tested
  // without a build. Fire-and-forget: it activates whatever was fetched last
  // launch and refreshes in the background, falling back to the shipped
  // defaults until one arrives. Startup never waits on the network.
  unawaited(_startupStep('ad config', AdConfig.instance.init));
  await _startupStep('ads', AdService.instance.initialize);
  await _startupStep('widget', WidgetService.instance.init);
  // Subscriptions are initialized in parallel; don't await to keep startup fast
  unawaited(_startupStep('subscriptions', SubscriptionService.instance.initialize));
  runApp(SimplePlateApp(storage: storage));
}

/// Runs one optional start-up step. A failure is reported (non-fatal) and
/// swallowed; a step that hangs is abandoned after [timeout] so it can never
/// hold the app on its launch screen.
Future<void> _startupStep(
  String name,
  Future<void> Function() step, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  try {
    await step().timeout(timeout);
  } catch (e, st) {
    debugPrint('Startup step "$name" failed: $e');
    try {
      await FirebaseCrashlytics.instance
          .recordError(e, st, reason: 'startup: $name', fatal: false);
    } catch (_) {}
  }
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
