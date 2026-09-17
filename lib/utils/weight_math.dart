import '../models/weight_entry.dart';

/// The unit a person weighs themselves in. Everything is stored in kilograms;
/// this only decides what they type and what they read back.
enum WeightUnit {
  kg,
  lb;

  static const _lbPerKg = 2.20462262185;

  String get symbol => this == WeightUnit.kg ? 'kg' : 'lb';

  /// Parses a stored preference; anything unrecognised is kilograms.
  static WeightUnit parse(String? raw) =>
      raw == 'lb' ? WeightUnit.lb : WeightUnit.kg;

  double fromKg(double kg) => this == WeightUnit.kg ? kg : kg * _lbPerKg;

  double toKg(double value) =>
      this == WeightUnit.kg ? value : value / _lbPerKg;

  /// "72.5 kg" / "160 lb": one decimal, trailing ".0" dropped.
  String format(double kg, {bool signed = false}) {
    final v = fromKg(kg);
    final rounded = (v * 10).round() / 10;
    var text = rounded == rounded.roundToDouble()
        ? rounded.round().toString()
        : rounded.toStringAsFixed(1);
    if (signed && rounded > 0) text = '+$text';
    if (signed && rounded < 0) text = '−${text.substring(1)}';
    return '$text $symbol';
  }
}

/// What the weight-trend chart plots for one window of days.
class WeightTrend {
  const WeightTrend({
    required this.days,
    required this.entries,
    required this.movingAverageKg,
  });

  /// Window length in days, ending today.
  final int days;

  /// Entries inside the window, oldest first.
  final List<WeightEntry> entries;

  /// A smoothed value for every entry in [entries]: the mean of all entries
  /// in the seven days up to and including that one. Day-to-day water and
  /// meal-timing swings mostly cancel out over a week, which is why the
  /// average — not the raw line — is what to read the direction off.
  final List<double> movingAverageKg;

  bool get isEmpty => entries.isEmpty;

  /// Kilograms gained (+) or lost (−) between the first and last entry in
  /// the window; null with fewer than two entries.
  double? get changeKg =>
      entries.length < 2 ? null : entries.last.kg - entries.first.kg;

  double? get latestKg => entries.isEmpty ? null : entries.last.kg;
}

/// Seven days, the standard smoothing window for body weight.
const movingAverageWindow = Duration(days: 7);

/// For each entry in [sorted] (oldest first), the mean weight of every entry
/// whose date falls in the [window] ending at that entry — so early points
/// average over fewer days rather than being left blank.
List<double> movingAverage(List<WeightEntry> sorted,
    {Duration window = movingAverageWindow}) {
  final out = <double>[];
  var start = 0;
  var sum = 0.0;
  for (var i = 0; i < sorted.length; i++) {
    sum += sorted[i].kg;
    // Drop entries that fell out of the window. The window is inclusive of
    // its first day: with a 7-day window, an entry logged 6 days ago counts,
    // one logged 7 days ago does not.
    final cutoff = sorted[i].loggedAt.subtract(window);
    while (!sorted[start].loggedAt.isAfter(cutoff)) {
      sum -= sorted[start].kg;
      start++;
    }
    out.add(sum / (i - start + 1));
  }
  return out;
}

/// The trend for the last [days] days of [log] (any order), as of [now].
/// The window is inclusive: with `days: 30`, an entry from 29 days ago is in
/// and one from 30 days ago is out.
WeightTrend weightTrend(List<WeightEntry> log,
    {required int days, DateTime? now}) {
  final today = now ?? DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  final cutoff = startOfToday.subtract(Duration(days: days - 1));
  final entries = log.where((e) => !e.loggedAt.isBefore(cutoff)).toList()
    ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
  return WeightTrend(
    days: days,
    entries: entries,
    movingAverageKg: movingAverage(entries),
  );
}
