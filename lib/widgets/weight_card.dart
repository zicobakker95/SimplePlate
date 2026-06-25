import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  Future<void> _log() async {
    final kg = double.tryParse(_ctrl.text);
    if (kg == null || kg < 20 || kg > 500) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid weight.')));
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
                      decoration: const InputDecoration(
                        labelText: 'Weight',
                        suffixText: 'kg',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      ),
                      onSubmitted: (_) => _log(),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Body weight',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        if (latest != null)
                          Text(
                            '${latest.kg} kg  ·  last logged today',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11),
                          )
                        else
                          const Text('Not logged today',
                              style: TextStyle(
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
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: _log,
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14)),
                    child: const Text('Save'),
                  ),
                ],
              )
            else
              TextButton(
                onPressed: () => setState(() => _editing = true),
                child: Text(
                    latest == null ? 'Log weight' : 'Update',
                    style: const TextStyle(color: AppColors.primary)),
              ),
          ],
        ),
      ),
    );
  }
}
