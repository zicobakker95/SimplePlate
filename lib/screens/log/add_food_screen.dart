import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food_entry.dart';
import '../../models/food_item.dart';
import '../../models/recipe.dart';
import '../../services/ad_service.dart';
import '../../services/food_store.dart';
import '../../services/openfoodfacts_service.dart';
import '../../theme/app_colors.dart';
import 'barcode_screen.dart';
import 'create_custom_food_screen.dart';
import 'create_recipe_screen.dart';
import 'food_detail_screen.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({
    super.key,
    this.defaultMeal = MealType.breakfast,
    this.pickMode = false,
  });

  final MealType defaultMeal;

  /// When true, tapping a food item pops the route with the selected [FoodItem]
  /// instead of navigating to the detail/log screen. Used by recipe builder.
  final bool pickMode;

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: widget.pickMode ? 2 : 3, vsync: this);

  final _searchCtrl = TextEditingController();
  List<FoodItem> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await OpenFoodFactsService.instance.search(query.trim());
      if (!mounted) return;
      setState(() {
        _loading = false;
        _results = items;
        if (items.isEmpty) {
          _error =
              'No results found for "$query".\nTry a more specific term or scan the barcode.';
        }
      });
    } on OpenFoodFactsException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _results = [];
        _error = '$e\nPull down to retry.';
      });
    }
  }

  Future<void> _scanBarcode() async {
    final unlocked = await AdService.instance.isScannerUnlockedToday();
    if (!mounted) return;

    if (!unlocked) {
      final watch = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Unlock barcode scanner'),
          content: const Text(
              'Watch a short ad to unlock the barcode scanner for the rest of the day.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
              label: const Text('Watch ad'),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      );
      if (watch != true || !mounted) return;

      setState(() => _loading = true);
      bool scannerReady = false;
      await AdService.instance.showScannerRewardedAd(
        onUnlocked: () => scannerReady = true,
        onCancelled: () => scannerReady = false,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      if (!scannerReady) {
        setState(
            () => _error = 'Ad unavailable right now. Try again in a moment.');
        return;
      }
    }

    final barcode = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const BarcodeScreen()));
    if (barcode == null || !mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final item =
          await OpenFoodFactsService.instance.fetchByBarcode(barcode);
      if (!mounted) return;
      setState(() => _loading = false);
      if (item == null) {
        setState(() => _error = 'Product not found in database.');
        return;
      }
      _handleItem(item);
    } on OpenFoodFactsException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  void _handleItem(FoodItem item) {
    if (widget.pickMode) {
      Navigator.of(context).pop(item);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              FoodDetailScreen(item: item, defaultMeal: widget.defaultMeal)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final tabs = widget.pickMode
        ? const [Tab(text: 'Search'), Tab(text: 'My Foods')]
        : const [
            Tab(text: 'Search'),
            Tab(text: 'Recent & Favourites'),
            Tab(text: 'Recipes'),
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pickMode ? 'Pick ingredient' : 'Add food'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── Search tab ──────────────────────────────────────────────────────
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _search,
                        decoration: InputDecoration(
                          hintText: 'Search foods…',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _results = []);
                                  })
                              : null,
                        ),
                        onChanged: (v) => setState(() {}),
                      ),
                    ),
                    if (!widget.pickMode) ...[
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceAlt),
                        icon: const Icon(Icons.qr_code_scanner_rounded,
                            color: AppColors.accent),
                        tooltip: 'Scan barcode',
                        onPressed: _scanBarcode,
                      ),
                    ],
                  ],
                ),
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.textMuted),
                      textAlign: TextAlign.center),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (_, i) =>
                        _FoodTile(item: _results[i], onTap: _handleItem),
                  ),
                ),
            ],
          ),

          // ── Recent & Favourites / My Foods tab ──────────────────────────────
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text('Create custom food'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateCustomFoodScreen(
                          defaultMeal: widget.defaultMeal),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              if (store.customFoods.isNotEmpty) ...[
                _sectionHeader('My Foods'),
                for (final item in store.customFoods)
                  _FoodTile(item: item, onTap: _handleItem),
              ],
              if (!widget.pickMode) ...[
                if (store.favourites.isNotEmpty) ...[
                  _sectionHeader('Favourites ⭐'),
                  for (final item in store.favourites)
                    _FoodTile(item: item, onTap: _handleItem),
                ],
                if (store.recents.isNotEmpty) ...[
                  _sectionHeader('Recent'),
                  for (final item in store.recents)
                    _FoodTile(item: item, onTap: _handleItem),
                ],
              ],
              if (store.customFoods.isEmpty &&
                  (widget.pickMode ||
                      (store.favourites.isEmpty && store.recents.isEmpty)))
                const Padding(
                  padding: EdgeInsets.all(48),
                  child: Text('No foods yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted)),
                ),
            ],
          ),

          // ── Recipes tab (normal mode only) ──────────────────────────────────
          if (!widget.pickMode)
            _RecipesTab(defaultMeal: widget.defaultMeal),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(label,
            style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
      );
}

// ── Recipes tab ─────────────────────────────────────────────────────────────

class _RecipesTab extends StatelessWidget {
  const _RecipesTab({required this.defaultMeal});
  final MealType defaultMeal;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.restaurant_menu_rounded, size: 18),
            label: const Text('Create new recipe'),
            onPressed: () => Navigator.of(context)
                .push(CreateRecipeScreen.route()),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        if (store.recipes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(48),
            child: Text('No recipes yet.\nTap "Create new recipe" to start.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted)),
          ),
        for (final recipe in store.recipes)
          _RecipeTile(recipe: recipe, defaultMeal: defaultMeal),
      ],
    );
  }
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({required this.recipe, required this.defaultMeal});
  final Recipe recipe;
  final MealType defaultMeal;

  @override
  Widget build(BuildContext context) {
    final store = context.read<FoodStore>();
    return ListTile(
      onTap: () => _logDialog(context, store),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.restaurant_menu_rounded,
            color: AppColors.primary, size: 20),
      ),
      title: Text(recipe.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${recipe.caloriesPerServing.round()} kcal/serving  ·  '
        '${recipe.servings} serving${recipe.servings != 1 ? 's' : ''}',
        style:
            const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert_rounded,
            color: AppColors.textMuted, size: 20),
        onSelected: (v) {
          if (v == 'edit') {
            Navigator.of(context)
                .push(CreateRecipeScreen.route(existing: recipe));
          } else if (v == 'delete') {
            store.deleteRecipe(recipe.id);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(
              value: 'delete',
              child: Text('Delete',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  Future<void> _logDialog(BuildContext context, FoodStore store) async {
    final servCtrl =
        TextEditingController(text: '1');
    MealType meal = defaultMeal;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(recipe.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${recipe.caloriesPerServing.round()} kcal per serving',
                style:
                    const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: servCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Servings to log'),
                onChanged: (_) => setS(() {}),
              ),
              const SizedBox(height: 12),
              DropdownButton<MealType>(
                value: meal,
                isExpanded: true,
                onChanged: (v) {
                  if (v != null) setS(() => meal = v);
                },
                items: MealType.values
                    .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m.label)))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final s = int.tryParse(servCtrl.text) ?? 1;
                Navigator.pop(ctx);
                await store.logRecipe(recipe, s, meal);
                if (context.mounted) Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: const Text('Log'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Food tile ────────────────────────────────────────────────────────────────

class _FoodTile extends StatelessWidget {
  const _FoodTile({required this.item, required this.onTap});
  final FoodItem item;
  final void Function(FoodItem) onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(item),
      title: Text(item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        item.brand.isNotEmpty
            ? '${item.brand}  ·  ${item.caloriesPer100.round()} kcal/100g'
            : '${item.caloriesPer100.round()} kcal / 100 g',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:
            const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: Consumer<FoodStore>(
        builder: (_, store, __) => IconButton(
          icon: Icon(
            store.isFavourite(item.id)
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: store.isFavourite(item.id)
                ? Colors.amber
                : AppColors.textMuted,
            size: 22,
          ),
          onPressed: () => store.toggleFavourite(item),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: store.isFavourite(item.id)
              ? 'Remove from favourites'
              : 'Add to favourites',
        ),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
