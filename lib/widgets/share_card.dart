import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';
import '../ui/kit.dart';

// Update these once the app is live in the stores.
const _androidStoreUrl =
    'https://play.google.com/store/apps/details?id=com.zibaentertainment.simple_plate';
// ignore: unused_element
const _iosStoreUrl =
    'https://apps.apple.com/app/platesimple/id0000000000'; // replace id
const _shareStoreUrl = _androidStoreUrl; // switch to _iosStoreUrl on iOS builds

/// Renders a summary card of the day's nutrition, captures it as a PNG,
/// and shares it via the OS share sheet.
///
/// The exported card always uses the light "kitchen table" look, whatever
/// theme the app is in, so a shared image is recognisably PlateSimple.
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.date,
    required this.calories,
    required this.goalCalories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.streak,
  });

  final DateTime date;
  final double calories;
  final int goalCalories;
  final double protein;
  final double carbs;
  final double fat;
  final int streak;

  /// Shows a preview sheet; the user taps Share to export the PNG.
  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    required double calories,
    required int goalCalories,
    required double protein,
    required double carbs,
    required double fat,
    required int streak,
  }) {
    return showPtSheet(
      context,
      title: context.l10n.shareDayTitle,
      builder: (_) => _ShareCardSheet(
        date: date,
        calories: calories,
        goalCalories: goalCalories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        streak: streak,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final goalMet =
        calories >= goalCalories * 0.85 && calories <= goalCalories * 1.1;
    final dateLabel = DateFormat('EEEE, MMM d', locale).format(date);
    const p = PlatePalette.light;

    // Force the light palette inside the card.
    return Theme(
      data: buildPlateTheme(Brightness.light),
      child: Container(
        width: 340,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        decoration: BoxDecoration(
          color: p.bg,
          borderRadius: BorderRadius.circular(Pt.rLg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Sprout(mood: SproutMood.happy, size: 34),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PlateSimple',
                        style: PtText.headline(color: p.text),
                      ),
                      Text(dateLabel, style: PtText.tiny(color: p.textMuted)),
                    ],
                  ),
                ),
                if (streak > 0)
                  PtTag(
                    label: l10n.dayStreak(streak),
                    color: p.honeyInk,
                    icon: Icons.local_fire_department_rounded,
                  ),
              ],
            ),
            const SizedBox(height: 18),
            PlateRing(
              value: goalCalories > 0 ? calories / goalCalories : 0,
              over: calories > goalCalories,
              size: 170,
              stroke: 13,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    calories.round().toString(),
                    style: PtText.number(32, color: p.text),
                  ),
                  Text('kcal', style: PtText.tiny(color: p.textMuted)),
                  Text(
                    l10n.ofGoal(goalCalories),
                    style: PtText.tiny(color: p.textMuted),
                  ),
                ],
              ),
            ),
            if (goalMet) ...[
              const SizedBox(height: 14),
              PtTag(
                label: l10n.goalHit,
                color: p.primary,
                icon: Icons.check_circle_rounded,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _MacroChip(l10n.macroProtein, protein, p.protein, p.proteinInk),
                _MacroChip(l10n.macroCarbs, carbs, p.carbs, p.carbsInk),
                _MacroChip(l10n.macroFat, fat, p.fat, p.fatInk),
              ],
            ),
            const SizedBox(height: 14),
            Text(l10n.trackedWith, style: PtText.tiny(color: p.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip(this.label, this.value, this.color, this.ink);
  final String label;
  final double value;
  final Color color;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    const p = PlatePalette.light;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(Pt.rSm),
          border: Border(bottom: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          children: [
            Text('${value.round()}g', style: PtText.number(17, color: ink)),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PtText.tiny(color: p.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet that previews the card and handles the capture + share flow.
class _ShareCardSheet extends StatefulWidget {
  const _ShareCardSheet({
    required this.date,
    required this.calories,
    required this.goalCalories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.streak,
  });

  final DateTime date;
  final double calories;
  final int goalCalories;
  final double protein;
  final double carbs;
  final double fat;
  final int streak;

  @override
  State<_ShareCardSheet> createState() => _ShareCardSheetState();
}

class _ShareCardSheetState extends State<_ShareCardSheet> {
  final _boundaryKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    final shareText = context.l10n.shareText(_shareStoreUrl);
    setState(() => _sharing = true);
    try {
      final boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/platesimple_day.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([
        XFile(file.path, mimeType: 'image/png'),
      ], text: shareText);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card preview — wrapped in RepaintBoundary for capture. Scaled
        // down on narrow phones; the captured PNG keeps its full size.
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: PopIn(
              child: RepaintBoundary(
                key: _boundaryKey,
                child: ShareCard(
                  date: widget.date,
                  calories: widget.calories,
                  goalCalories: widget.goalCalories,
                  protein: widget.protein,
                  carbs: widget.carbs,
                  fat: widget.fat,
                  streak: widget.streak,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        PtButton(
          label: _sharing ? l10n.preparing : l10n.share,
          icon: Icons.ios_share_rounded,
          loading: _sharing,
          expand: true,
          onPressed: _sharing ? null : _share,
        ),
      ],
    );
  }
}
