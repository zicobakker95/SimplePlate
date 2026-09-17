// The two new Premium cards, pumped in both entitlement states: the free
// view must sell the feature and open the paywall; the paid view must show
// the real thing. Layout errors (an overflowing overlay, say) surface here
// as test failures, which is the point.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_plate/l10n/app_localizations.dart';
import 'package:simple_plate/services/food_store.dart';
import 'package:simple_plate/services/storage_service.dart';
import 'package:simple_plate/services/subscription_service.dart';
import 'package:simple_plate/theme/app_theme.dart';
import 'package:simple_plate/utils/weight_math.dart';
import 'package:simple_plate/widgets/health_card.dart';
import 'package:simple_plate/widgets/health_sync_setting.dart';
import 'package:simple_plate/widgets/weight_card.dart';
import 'package:simple_plate/widgets/weight_trend_card.dart';

Widget host(FoodStore store, Widget child) => ChangeNotifierProvider.value(
      value: store,
      child: MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ListView(children: [child])),
      ),
    );

void main() {
  late FoodStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = FoodStore(await StorageService.init());
    await SubscriptionService.instance.debugSetPremium(false);
  });

  tearDown(() => SubscriptionService.instance.debugSetPremium(false));

  /// Five weigh-ins over two weeks, 80 → 78.8 kg: a 1.2 kg loss.
  Future<void> logSomeWeights() async {
    final now = DateTime.now();
    for (var d = 12; d >= 0; d -= 3) {
      await store.logWeight(80 - (12 - d) * 0.1,
          at: now.subtract(Duration(days: d)));
    }
  }

  final trendChart = find.byWidgetPredicate((w) =>
      w is CustomPaint && w.painter.runtimeType.toString() == '_TrendPainter');

  group('WeightTrendCard', () {
    testWidgets('free: locked preview with an upgrade button', (tester) async {
      await tester.pumpWidget(host(store, const WeightTrendCard()));
      await tester.pumpAndSettle();

      expect(find.text('Weight trend'), findsWidgets);
      expect(find.text('Premium feature'), findsOneWidget);
      expect(find.text('Upgrade to Premium'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('premium: chart, legend and change over the period',
        (tester) async {
      await SubscriptionService.instance.debugSetPremium(true);
      await logSomeWeights();
      await tester.pumpWidget(host(store, const WeightTrendCard()));
      await tester.pumpAndSettle();

      expect(find.text('Upgrade to Premium'), findsNothing);
      expect(find.text('7-day average'), findsOneWidget);
      expect(find.text('78.8 kg'), findsOneWidget);
      expect(find.text('−1.2 kg over 30 days'), findsOneWidget);
      expect(trendChart, findsOneWidget);
      expect(find.text('30 days'), findsOneWidget);
      expect(find.text('90 days'), findsOneWidget);

      await tester.tap(find.text('90 days'));
      await tester.pumpAndSettle();
      expect(find.text('−1.2 kg over 90 days'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('premium, one entry: asks for more, no chart', (tester) async {
      await SubscriptionService.instance.debugSetPremium(true);
      await store.logWeight(80);
      await tester.pumpWidget(host(store, const WeightTrendCard()));
      await tester.pumpAndSettle();

      expect(find.textContaining('couple more times'), findsOneWidget);
      expect(trendChart, findsNothing);
    });

    testWidgets('follows the unit preference', (tester) async {
      await SubscriptionService.instance.debugSetPremium(true);
      await logSomeWeights();
      await store.setWeightUnit(WeightUnit.lb);
      await tester.pumpWidget(host(store, const WeightTrendCard()));
      await tester.pumpAndSettle();

      expect(find.text('−2.6 lb over 30 days'), findsOneWidget);
      expect(find.text('173.7 lb'), findsOneWidget);
    });
  });

  group('WeightCard', () {
    testWidgets('logs in the chosen unit and stores kilograms',
        (tester) async {
      await store.setWeightUnit(WeightUnit.lb);
      await tester.pumpWidget(host(store, const WeightCard()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log weight'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '176.4');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(store.latestWeight!.kg, closeTo(80, 0.05));
      expect(find.textContaining('176.4 lb'), findsOneWidget);
    });
  });

  group('HealthSyncCard', () {
    testWidgets('free: teaser opens Premium, nothing is read',
        (tester) async {
      await tester.pumpWidget(host(store, const HealthSyncCard()));
      await tester.pumpAndSettle();

      expect(find.text('Upgrade to Premium'), findsOneWidget);
      expect(find.text('Connect Health'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('premium with sync off: offers to connect', (tester) async {
      await SubscriptionService.instance.debugSetPremium(true);
      await tester.pumpWidget(host(store, const HealthSyncCard()));
      await tester.pumpAndSettle();

      expect(find.text('Connect Health'), findsOneWidget);
      expect(find.text('Upgrade to Premium'), findsNothing);
    });
  });

  group('HealthSyncSetting', () {
    testWidgets('free: switch is off, explanation is readable, Premium noted',
        (tester) async {
      await tester.pumpWidget(host(store, const HealthSyncSetting()));
      await tester.pumpAndSettle();

      final sw = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(sw.value, isFalse);
      expect(find.text('Health sync is part of Premium.'), findsOneWidget);
      expect(find.textContaining('Nothing is sent anywhere else.'),
          findsOneWidget);
    });

    testWidgets('switching off never touches Health', (tester) async {
      await SubscriptionService.instance.debugSetPremium(true);
      await store.setHealthSyncEnabled(true);
      await tester.pumpWidget(host(store, const HealthSyncSetting()));
      await tester.pumpAndSettle();

      expect(
          tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
          isTrue);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(store.healthSyncEnabled, isFalse);
      expect(tester.takeException(), isNull);
    });
  });
}
