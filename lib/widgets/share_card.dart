import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_colors.dart';

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
/// Usage: call [ShareCard.share] from a button.
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
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
    final pct = goalCalories > 0
        ? (calories / goalCalories).clamp(0.0, 1.0)
        : 0.0;
    final goalMet = calories >= goalCalories * 0.85 &&
        calories <= goalCalories * 1.1;
    final dateLabel = DateFormat('EEEE, MMM d').format(date);

    return Container(
      width: 360,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2318),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant_menu_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PlateSimple',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  Text(dateLabel,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11)),
                ],
              ),
              const Spacer(),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: Colors.orange, size: 14),
                      const SizedBox(width: 4),
                      Text('$streak day${streak == 1 ? '' : 's'}',
                          style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Calorie ring
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 10,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goalMet ? AppColors.primary : AppColors.calories,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    calories.round().toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800),
                  ),
                  const Text('kcal',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 11)),
                  Text(
                    'of $goalCalories goal',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Goal badge
          if (goalMet)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.primary, size: 14),
                  SizedBox(width: 6),
                  Text('Goal hit!',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // Macro row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MacroChip('Protein', protein, 'g', AppColors.protein),
              _MacroChip('Carbs', carbs, 'g', AppColors.carbs),
              _MacroChip('Fat', fat, 'g', AppColors.fat),
            ],
          ),
          const SizedBox(height: 20),

          // Footer
          const Text(
            'tracked with PlateSimple',
            style: TextStyle(color: Colors.white24, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip(this.label, this.value, this.unit, this.color);
  final String label, unit;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${value.round()}$unit',
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 17),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: Colors.white54, fontSize: 11)),
      ],
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
    setState(() => _sharing = true);
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/platesimple_day.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'My nutrition today — tracked with PlateSimple 🥗\n$_shareStoreUrl',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text('Share your day',
              style:
                  TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 20),

          // Card preview — wrapped in RepaintBoundary for capture
          RepaintBoundary(
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

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _sharing ? null : _share,
              icon: _sharing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.share_rounded, size: 18),
              label:
                  Text(_sharing ? 'Preparing…' : 'Share'),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
