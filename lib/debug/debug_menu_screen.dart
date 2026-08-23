import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/food_entry.dart';
import '../models/food_item.dart';
import '../services/food_store.dart';
import '../services/notification_service.dart';
import '../services/subscription_service.dart';
import 'debug_marker.dart';

/// Developer tools. Debug builds only — see [debugToolsTile].
///
/// A calorie tracker only gets interesting once there is food in it: the
/// day ring, the history charts, the streak and the premium screens all need
/// days of logged entries. These write that through the real store, so what
/// they produce is what a user would have logged by hand.
class DebugMenuScreen extends StatefulWidget {
  const DebugMenuScreen({super.key});

  @override
  State<DebugMenuScreen> createState() => _DebugMenuScreenState();
}

class _DebugMenuScreenState extends State<DebugMenuScreen> {
  final _plugin = FlutterLocalNotificationsPlugin();
  List<PendingNotificationRequest> _pending = const [];
  String _permission = '…';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final pending = await _plugin.pendingNotificationRequests();
    bool? enabled;
    try {
      enabled = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _pending = pending;
      _permission = '${enabled ?? "?"}';
    });
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _run(String label, Future<void> Function() body) async {
    try {
      await body();
      _toast(label);
    } catch (e) {
      _toast('FAILED: $e');
    }
    await _refresh();
    if (mounted) setState(() {});
  }

  FoodStore get _store => context.read<FoodStore>();

  // ---------------------------------------------------------------- seeding

  /// A realistic day: four meals that land near a normal target rather than
  /// four identical rows, so the ring and the macro split look like something.
  static const _menu = <(String, double, double, double, double, MealType)>[
    ('Porridge with banana', 118, 3.2, 21, 2.1, MealType.breakfast),
    ('Chicken salad', 152, 21, 6, 4.8, MealType.lunch),
    ('Salmon, rice, greens', 198, 17, 22, 6.4, MealType.dinner),
    ('Greek yoghurt', 97, 9, 4, 4.2, MealType.snack),
  ];

  Future<void> _logDay(DateTime day) async {
    for (final (name, kcal, p, c, f, meal) in _menu) {
      await _store.logFood(
        FoodItem(
          id: 'debug-${name.hashCode}',
          name: name,
          brand: 'Debug',
          caloriesPer100: kcal,
          proteinPer100: p,
          carbsPer100: c,
          fatPer100: f,
        ),
        200,
        meal,
        at: day,
      );
    }
  }

  Future<void> _seedWeek() async {
    for (var i = 0; i < 7; i++) {
      await _logDay(DateTime.now().subtract(Duration(days: i)));
    }
  }

  Future<void> _setStreak(int days) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('sp.streak', days);
  }

  Future<void> _fillWater() async {
    for (var i = 0; i < 8; i++) {
      await _store.addWater();
    }
  }

  Future<void> _resetOnboarding() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('sp.onboarding.done', false);
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    // SubscriptionService is a singleton, not a provider — a pushed route
    // cannot see it through the widget tree. _run() calls setState, so the
    // switch still reflects a toggle.
    final subs = SubscriptionService.instance;
    final store = context.watch<FoodStore>();
    final now = tz.TZDateTime.now(tz.local);
    final nextMinute = DateTime.now().add(const Duration(minutes: 1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Tools'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PlateSimple — debug build',
                      style: TextStyle(fontFamily: 'monospace')),
                  const SizedBox(height: 6),
                  Text(
                    'today=${store.todayCalories().round()} kcal   '
                    'premium=${subs.isPremium}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'notifPermission=$_permission   '
                    'pending=${_pending.length}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 6),
                  Text('${tz.local.name}  ${now.toString().split('.').first}',
                      style: const TextStyle(fontFamily: 'monospace')),
                  const SizedBox(height: 6),
                  Text(kDebugOnlyMarker,
                      style:
                          const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ),

          _header('Premium'),
          SwitchListTile(
            secondary: const Icon(Icons.workspace_premium_rounded),
            title: const Text('Premium active'),
            subtitle: const Text(
              'Every gated screen reads this. Survives a restart.',
              style: TextStyle(fontSize: 12),
            ),
            value: subs.isPremium,
            onChanged: (v) =>
                _run('Premium = $v', () => subs.debugSetPremium(v)),
          ),

          _header('Notifications'),
          _tile(
            'Daily reminder — fire now',
            'What the evening nudge looks like in the shade.',
            Icons.notifications_active_rounded,
            () => _run('Reminder sent', () async {
              await NotificationService.instance.scheduleDaily(
                hour: nextMinute.hour,
                minute: nextMinute.minute,
                title: 'Did you log dinner?',
                body: 'Tap to finish today in PlateSimple.',
              );
            }),
          ),
          _tile(
            'Schedule for the next minute',
            'Real scheduleDaily(). Repeats daily until cancelled.',
            Icons.alarm_rounded,
            () => _run(
                'Scheduled for ${nextMinute.hour}:'
                '${nextMinute.minute.toString().padLeft(2, '0')}', () async {
              await NotificationService.instance.scheduleDaily(
                hour: nextMinute.hour,
                minute: nextMinute.minute,
                title: 'Did you log dinner?',
                body: 'Scheduled test — repeats daily.',
              );
            }),
          ),
          _tile(
            'Request notification permission',
            'Production requestPermissions().',
            Icons.lock_open_rounded,
            () => _run('Permission flow finished', () async {
              await NotificationService.instance.requestPermissions(context);
            }),
          ),
          _tile(
            'Cancel the reminder',
            'Production cancelReminder(). Queue below should empty.',
            Icons.notifications_off_rounded,
            () => _run('Reminder cancelled',
                () => NotificationService.instance.cancelReminder()),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pending (${_pending.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_pending.isEmpty)
                    const Text('Nothing scheduled.',
                        style: TextStyle(color: Colors.grey))
                  else
                    ..._pending.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                              '#${p.id}  ${p.title ?? ''}\n     ${p.body ?? ''}',
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 11)),
                        )),
                ],
              ),
            ),
          ),

          _header('Test data'),
          _tile(
            'Log a full day',
            'Breakfast, lunch, dinner and a snack — fills the ring and the '
                'macro split.',
            Icons.restaurant_rounded,
            () => _run('Day logged', () => _logDay(DateTime.now())),
          ),
          _tile(
            'Log a week',
            'Seven days of meals so History and the charts have a shape.',
            Icons.calendar_month_rounded,
            () => _run('Week logged', _seedWeek),
          ),
          _tile(
            'Fill water to the goal',
            'Eight glasses through the real addWater().',
            Icons.local_drink_rounded,
            () => _run('Water filled', _fillWater),
          ),
          _tile(
            'Set streak to 30 days',
            'Exercises the streak copy without logging for a month.',
            Icons.local_fire_department_rounded,
            () => _run('Streak = 30', () => _setStreak(30)),
          ),

          _header('State'),
          _tile(
            'Reset onboarding',
            'Next launch starts at the welcome flow.',
            Icons.restart_alt_rounded,
            () => _run('Onboarding reset — restart the app', _resetOnboarding),
          ),

          _header('Diagnostics'),
          _tile(
            'Force a test crash',
            'Confirms Crashlytics is wired. Kills the app on purpose.',
            Icons.bug_report_rounded,
            () => _run('Crashing…', () async {
              await FirebaseCrashlytics.instance
                  .log('Deliberate crash from Debug Tools');
              FirebaseCrashlytics.instance.crash();
            }),
          ),
          _tile(
            'Throw a caught exception',
            'Non-fatal report — appears in Crashlytics without killing the app.',
            Icons.report_gmailerrorred_rounded,
            () => _run('Non-fatal recorded', () async {
              await FirebaseCrashlytics.instance.recordError(
                StateError('Debug Tools non-fatal test'),
                StackTrace.current,
                fatal: false,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
        child: Text(
          t.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      );

  Widget _tile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) =>
      Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          onTap: onTap,
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      );
}

/// The Goals-screen entry point — null in release.
///
/// `kDebugMode` is a compile-time constant, so in a release build this is a
/// dead branch and the AOT compiler drops [DebugMenuScreen] and its strings.
/// `tool/check_release_clean.sh` greps a built AAB for [kDebugOnlyMarker] to
/// prove it actually happened.
Widget? debugToolsTile(BuildContext context) {
  if (!kDebugMode) return null;
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: ListTile(
      leading: const Icon(Icons.construction_rounded),
      title: const Text('Debug Tools'),
      subtitle: const Text('Debug builds only — not in release',
          style: TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DebugMenuScreen()),
      ),
    ),
  );
}
