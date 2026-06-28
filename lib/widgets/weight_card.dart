import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/weight_entry.dart';
import '../services/food_store.dart';
import '../theme/app_colors.dart';

/// Small card on the Today screen for logging and displaying body weight.
class WeightCard extends StatefulWidget {
  const WeightCard({super.key});

  @override
  State<WeightCard> createState() => _WeightCardState();
}

class _WeightCardState extends State<WeightCard> {
  final _ctrl = TextEditingController();
  bool _editing = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _weightSubtitle(WeightEntry entry) {
    final l10n = context.l10n;
    final today = DateTime.now();
    final logged = entry.loggedAt;
    final isToday = logged.year == today.year &&
        logged.month == today.month &&
        logged.day == today.day;
    final kg = entry.kg.toString();
    if (isToday) return l10n.weightSubtitleToday(kg);
    final locale = Localizations.localeOf(context).toString();
    return l10n.weightSubtitleDate(
        kg, DateFormat('MMM d', locale).format(logged));
  }

  Future<void> _log() async {
    final kg = double.tryParse(_ctrl.text);
    if (kg == null || kg < 20 || kg > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.weightInvalid)));
      return;
    }
    await context.read<FoodStore>().logWeight(kg);
    if (!mounted) return;
    setState(() {
      _editing = false;
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final l10n = context.l10n;
    final latest = store.latestWeight;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            const Icon(Icons.monitor_weight_outlined,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: _editing
                  ? TextField(
                      controller: _ctrl,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.fieldWeight,
                        suffixText: 'kg',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                      ),
                      onSubmitted: (_) => _log(),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.bodyWeight,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        if (latest != null)
                          Text(
                            _weightSubtitle(latest),
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11),
                          )
                        else
                          Text(l10n.notLoggedToday,
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
            ),
            const SizedBox(width: 8),
            if (_editing)
              Row(
                children: [
                  TextButton(
                    onPressed: () => setState(() {
                      _editing = false;
                      _ctrl.clear();
                    }),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: _log,
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14)),
                    child: Text(l10n.save),
                  ),
                ],
              )
            else
              TextButton(
                onPressed: () => setState(() => _editing = true),
                child: Text(
                    latest == null ? l10n.logWeight : l10n.update,
                    style: const TextStyle(color: AppColors.primary)),
              ),
          ],
        ),
      ),
    );
  }
}
