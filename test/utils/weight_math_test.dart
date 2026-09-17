// Unit conversion and the 7-day smoothing behind the weight-trend chart.
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/models/weight_entry.dart';
import 'package:simple_plate/utils/weight_math.dart';

WeightEntry entry(DateTime at, double kg) =>
    WeightEntry(id: at.toIso8601String(), kg: kg, loggedAt: at);

final day0 = DateTime(2026, 9, 1, 8);
WeightEntry onDay(int d, double kg) => entry(day0.add(Duration(days: d)), kg);

void main() {
  group('WeightUnit', () {
    test('kilograms pass through untouched', () {
      expect(WeightUnit.kg.fromKg(72.5), 72.5);
      expect(WeightUnit.kg.toKg(72.5), 72.5);
    });

    test('pounds convert both ways and round-trip', () {
      expect(WeightUnit.lb.fromKg(1), closeTo(2.20462, 1e-5));
      expect(WeightUnit.lb.toKg(2.20462262185), closeTo(1, 1e-9));
      expect(WeightUnit.lb.toKg(WeightUnit.lb.fromKg(83.4)), closeTo(83.4, 1e-9));
    });

    test('formats one decimal in the chosen unit, dropping ".0"', () {
      expect(WeightUnit.kg.format(72.0), '72 kg');
      expect(WeightUnit.kg.format(72.46), '72.5 kg');
      expect(WeightUnit.lb.format(72.5), '159.8 lb');
    });

    test('signed formatting marks a gain and a loss', () {
      expect(WeightUnit.kg.format(1.2, signed: true), '+1.2 kg');
      expect(WeightUnit.kg.format(-0.8, signed: true), '−0.8 kg');
      expect(WeightUnit.kg.format(0, signed: true), '0 kg');
    });

    test('a stored preference parses, anything else is kilograms', () {
      expect(WeightUnit.parse('lb'), WeightUnit.lb);
      expect(WeightUnit.parse('kg'), WeightUnit.kg);
      expect(WeightUnit.parse(null), WeightUnit.kg);
      expect(WeightUnit.parse('stone'), WeightUnit.kg);
    });
  });

  group('movingAverage', () {
    test('a single entry is its own average', () {
      expect(movingAverage([onDay(0, 80)]), [80]);
    });

    test('averages the seven days ending at each entry', () {
      final log = [for (var d = 0; d < 10; d++) onDay(d, 80.0 + d)];
      final avg = movingAverage(log);
      // Day 9 averages days 3..9: (83+84+...+89)/7 = 86.
      expect(avg.last, closeTo(86, 1e-9));
      // Day 6 is the first with a full window: days 0..6 → 83.
      expect(avg[6], closeTo(83, 1e-9));
      // Day 2 only has three days to average: (80+81+82)/3.
      expect(avg[2], closeTo(81, 1e-9));
    });

    test('an entry exactly seven days back has fallen out of the window', () {
      final avg = movingAverage([onDay(0, 100), onDay(7, 80)]);
      expect(avg.last, 80);
    });

    test('an entry six days back is still in', () {
      final avg = movingAverage([onDay(0, 100), onDay(6, 80)]);
      expect(avg.last, 90);
    });

    test('smooths a spike that the raw line would show', () {
      final log = [
        onDay(0, 80),
        onDay(1, 80),
        onDay(2, 80),
        onDay(3, 82.5), // the big dinner
        onDay(4, 80),
      ];
      final avg = movingAverage(log);
      expect(avg[3], closeTo(80.625, 1e-9));
      expect(avg[3], lessThan(82.5));
    });
  });

  group('weightTrend', () {
    final now = DateTime(2026, 9, 30, 20);

    test('keeps only the entries inside the window, oldest first', () {
      final trend = weightTrend([
        entry(DateTime(2026, 9, 29), 79),
        entry(DateTime(2026, 8, 1), 85), // 60 days back
        entry(DateTime(2026, 9, 1), 81), // 29 days back: in
        entry(DateTime(2026, 8, 31), 82), // 30 days back: out
      ], days: 30, now: now);
      expect(trend.entries.map((e) => e.kg), [81, 79]);
      expect(trend.movingAverageKg, hasLength(2));
    });

    test('a 90-day window includes what a 30-day one dropped', () {
      final log = [
        entry(DateTime(2026, 8, 1), 85),
        entry(DateTime(2026, 9, 29), 79),
      ];
      expect(weightTrend(log, days: 30, now: now).entries, hasLength(1));
      expect(weightTrend(log, days: 90, now: now).entries, hasLength(2));
    });

    test('change is last minus first, and null with one entry', () {
      final trend = weightTrend([
        entry(DateTime(2026, 9, 2), 82),
        entry(DateTime(2026, 9, 28), 80.5),
      ], days: 30, now: now);
      expect(trend.changeKg, closeTo(-1.5, 1e-9));
      expect(trend.latestKg, 80.5);

      final single = weightTrend([entry(DateTime(2026, 9, 2), 82)],
          days: 30, now: now);
      expect(single.changeKg, isNull);
      expect(single.latestKg, 82);
    });

    test('an empty log is an empty trend, not an error', () {
      final trend = weightTrend(const [], days: 30, now: now);
      expect(trend.isEmpty, isTrue);
      expect(trend.changeKg, isNull);
      expect(trend.latestKg, isNull);
    });
  });
}
