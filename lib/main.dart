import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'screens/home/home_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/ad_service.dart';
import 'services/food_store.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/subscription_service.dart';
import 'services/widget_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.init();
  await NotificationService.instance.init();
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
        home: storage.onboardingDone
            ? const HomeShell()
            : const OnboardingScreen(),
      ),
    );
  }
}
