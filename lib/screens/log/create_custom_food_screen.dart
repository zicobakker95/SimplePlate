import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/l10n.dart';
import '../../models/food_entry.dart';
import '../../models/food_item.dart';
import '../../services/food_store.dart';
import '../../ui/kit.dart';
import 'food_detail_screen.dart';

/// Screen for creating a custom food item.
/// After saving, opens FoodDetailScreen so the user can log a serving immediately.
class CreateCustomFoodScreen extends StatefulWidget {
  const CreateCustomFoodScreen({
    super.key,
    required this.defaultMeal,
    this.initialName,
  });
  final MealType defaultMeal;

  /// Pre-fills the name — the search screen passes the query that found
  /// nothing, so "Add as custom food" starts with the typing already done.
  final String? initialName;

  @override
  State<CreateCustomFoodScreen> createState() => _CreateCustomFoodScreenState();
}

class _CreateCustomFoodScreenState extends State<CreateCustomFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.initialName ?? '');
  final _brandCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _servingCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // The macro preview ring follows the typing.
    for (final c in [_proteinCtrl, _carbCtrl, _fatCtrl, _calCtrl]) {
      c.addListener(_refresh);
    }
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    _servingCtrl.dispose();
    super.dispose();
  }

  /// The serving size as typed, or null when it is blank or not a usable
  /// positive number.
  double? get _parsedServingSize {
    final raw = _servingCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    final v = double.tryParse(raw);
    if (v == null || v <= 0) return null;
    return v;
  }

  double _num(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = FoodItem(
      id: 'custom-${const Uuid().v4()}',
      name: _nameCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      caloriesPer100: double.parse(_calCtrl.text),
      proteinPer100: double.parse(_proteinCtrl.text),
      carbsPer100: double.parse(_carbCtrl.text),
      fatPer100: double.parse(_fatCtrl.text),
      isCustom: true,
      // Optional. Blank, unparseable or non-positive all mean "no serving
      // size", which is what null already says -- better than a zero that
      // would divide every amount into infinity servings.
      servingSizeGrams: _parsedServingSize,
    );

    await context.read<FoodStore>().addCustomFood(item);
    if (!mounted) return;
    setState(() => _saving = false);

    // Replace this screen with FoodDetailScreen so the user logs a serving
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            FoodDetailScreen(item: item, defaultMeal: widget.defaultMeal),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String suffix = '',
    bool required = true,
    int maxLength = 80,
    bool decimal = true,
    IconData? icon,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: ctrl,
        maxLength: maxLength,
        textCapitalization: decimal
            ? TextCapitalization.none
            : TextCapitalization.sentences,
        keyboardType: decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix.isEmpty ? null : suffix,
          counterText: '',
          prefixIcon: icon == null ? null : Icon(icon, color: iconColor),
        ),
        validator: required
            ? (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return context.l10n.fieldRequired;
                if (decimal && double.tryParse(s) == null) {
                  return context.l10n.enterValidNumber;
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createCustomFoodTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Pt.gutter, 4, Pt.gutter, 24),
          children: [
            FadeSlideIn(
              child: PtCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.foodDetailsSection,
                      style: PtText.headline(color: p.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.valuesPer100,
                      style: PtText.small(color: p.textMuted),
                    ),
                    const SizedBox(height: 10),
                    _field(
                      l10n.foodNameLabel,
                      _nameCtrl,
                      decimal: false,
                      icon: Icons.restaurant_rounded,
                    ),
                    _field(
                      l10n.brandOptional,
                      _brandCtrl,
                      required: false,
                      decimal: false,
                      icon: Icons.storefront_outlined,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            FadeSlideIn(
              index: 1,
              child: PtCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.nutritionPer100,
                            style: PtText.headline(color: p.text),
                          ),
                        ),
                        // Live split of what has been typed so far.
                        MacroSplitRing(
                          protein: _num(_proteinCtrl),
                          carbs: _num(_carbCtrl),
                          fat: _num(_fatCtrl),
                          size: 40,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _field(
                      l10n.fieldCalories,
                      _calCtrl,
                      suffix: 'kcal',
                      icon: Icons.local_fire_department_rounded,
                      iconColor: p.fresh,
                    ),
                    _field(
                      l10n.fieldProtein,
                      _proteinCtrl,
                      suffix: 'g',
                      icon: Icons.circle,
                      iconColor: p.protein,
                    ),
                    _field(
                      l10n.fieldCarbohydrates,
                      _carbCtrl,
                      suffix: 'g',
                      icon: Icons.circle,
                      iconColor: p.carbs,
                    ),
                    _field(
                      l10n.fieldFat,
                      _fatCtrl,
                      suffix: 'g',
                      icon: Icons.circle,
                      iconColor: p.fat,
                    ),
                    const SizedBox(height: 6),
                    // Optional, and the only way a custom food can show
                    // servings -- scanned foods get this from Open Food Facts.
                    _field(
                      l10n.gramsPerServingLabel,
                      _servingCtrl,
                      suffix: 'g',
                      required: false,
                      icon: Icons.scale_outlined,
                    ),
                    Text(
                      l10n.gramsPerServingHint,
                      style: PtText.small(color: p.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Pt.gutter, 8, Pt.gutter, 12),
          child: PtButton(
            label: l10n.saveAndLog,
            icon: Icons.check_rounded,
            expand: true,
            loading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ),
      ),
    );
  }
}
