import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/cross_promo.dart';

/// Streaks was renamed to ZiBa Habits after a trademark claim: the old name
/// must never be shown, while the internal id and the store ids stay.
void main() {
  test('the habit tracker is listed as ZiBa Habits, never as Streaks', () {
    final habits = kZibaApps.firstWhere((a) => a.id == 'streaks');
    expect(habits.name, 'ZiBa Habits');
    expect(habits.appleId, '6780628137');
    expect(habits.androidId, 'com.streaks.zibaentertainment');
    for (final a in kZibaApps) {
      expect(a.name.toLowerCase(), isNot(contains('streaks')), reason: a.id);
      expect(a.tagline.toLowerCase(), isNot(contains('streaks')), reason: a.id);
    }
  });
}
