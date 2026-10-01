import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/weight_entry.dart';
import '../services/food_store.dart';
import '../ui/kit.dart';
import '../utils/weight_math.dart';

/// Small card for logging and displaying body weight, in the user's unit.
/// Lives on Today and again under Goals, so a weigh-in is never more than
/// one tap from wherever the app was opened.
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

  String _weightSubtitle(WeightEntry entry, WeightUnit unit) {
    final l10n = context.l10n;
    final today = DateTime.now();
    final logged = entry.loggedAt;
    final isToday =
        logged.year == today.year &&
        logged.month == today.month &&
        logged.day == today.day;
    final weight = unit.format(entry.kg);
    if (isToday) return l10n.weightSubtitleToday(weight);
    final locale = Localizations.localeOf(context).toString();
    return l10n.weightSubtitleDate(
      weight,
      DateFormat('MMM d', locale).format(logged),
    );
  }

  Future<void> _log() async {
    final store = context.read<FoodStore>();
    final typed = double.tryParse(_ctrl.text.trim().replaceAll(',', '.'));
    // Bounds are checked in kilograms so they mean the same in either unit.
    final kg = typed == null ? null : store.weightUnit.toKg(typed);
    if (kg == null || kg < 20 || kg > 500) {
      showPtToast(
        context,
        context.l10n.weightInvalid,
        icon: Icons.error_outline_rounded,
        tone: PtToastTone.warning,
      );
      return;
    }
    await store.logWeight(kg);
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
    final p = context.pal;
    final latest = store.latestWeight;
    final unit = store.weightUnit;

    return PtCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: AnimatedSize(
        duration: Pt.base,
        curve: Pt.ease,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: Pt.base,
          child: _editing
              ? Column(
                  key: const ValueKey('edit'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _ctrl,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: PtText.number(18, color: p.text),
                      decoration: InputDecoration(
                        labelText: l10n.fieldWeight,
                        suffixText: unit.symbol,
                        prefixIcon: const Icon(Icons.monitor_weight_outlined),
                      ),
                      onSubmitted: (_) => _log(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PtButton(
                          label: l10n.cancel,
                          tone: PtButtonTone.ghost,
                          compact: true,
                          onPressed: () => setState(() {
                            _editing = false;
                            _ctrl.clear();
                          }),
                        ),
                        const SizedBox(width: 8),
                        PtButton(
                          label: l10n.save,
                          compact: true,
                          haptic: true,
                          onPressed: _log,
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('show'),
                  children: [
                    IconBadge(
                      Icons.monitor_weight_outlined,
                      color: p.primary,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.bodyWeight,
                            style: PtText.tile(
                              color: p.text,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            latest != null
                                ? _weightSubtitle(latest, unit)
                                : l10n.notLoggedToday,
                            style: PtText.small(color: p.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    PtButton(
                      label: latest == null ? l10n.logWeight : l10n.update,
                      tone: PtButtonTone.soft,
                      compact: true,
                      onPressed: () => setState(() => _editing = true),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
