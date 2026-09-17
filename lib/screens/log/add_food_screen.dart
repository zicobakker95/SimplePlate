import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/food_entry.dart';
import '../../models/food_item.dart';
import '../../models/recipe.dart';
import '../../services/ad_service.dart';
import '../../services/food_search_service.dart';
import '../../services/food_store.dart';
import '../../services/openfoodfacts_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ad_banner.dart';
import '../../widgets/quick_add_sheet.dart';
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

  /// Typing pauses this long before a live search fires. Local matches
  /// (recents, custom foods) update on every keystroke regardless.
  static const _debounce = Duration(milliseconds: 500);

  final _searchCtrl = TextEditingController();
  Timer? _debounceTimer;
  StreamSubscription<FoodSearchResult>? _sub;

  /// The query the current [_results] / [_error] belong to.
  String _searchedQuery = '';
  List<FoodItem> _results = [];
  bool _fromCache = false;
  bool _offline = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _sub?.cancel();
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _query => _searchCtrl.text.trim();

  void _onQueryChanged(String value) {
    _debounceTimer?.cancel();
    final q = value.trim();
    if (q.isEmpty) {
      _sub?.cancel();
      setState(() {
        _searchedQuery = '';
        _results = [];
        _error = null;
        _loading = false;
      });
      return;
    }
    setState(() {}); // local matches + clear button
    if (q.length < 2) return;
    _debounceTimer = Timer(_debounce, () => _search(q));
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    _debounceTimer?.cancel();
    if (q.isEmpty) return;
    if (q == _searchedQuery && !_loading && _error == null) return;

    await _sub?.cancel();
    setState(() {
      _searchedQuery = q;
      _loading = true;
      _error = null;
      _fromCache = false;
      _offline = false;
    });
    final locale = Localizations.localeOf(context);
    _sub = FoodSearchService.instance.search(q, locale: locale).listen(
      (result) {
        if (!mounted || _searchedQuery != q) return;
        setState(() {
          _results = result.items;
          _fromCache = result.fromCache;
          _offline = result.offline;
          // A cached answer keeps the spinner: the live one is still coming.
          _loading = result.fromCache && !result.offline;
          _error = null;
        });
      },
      onError: (Object e) {
        if (!mounted || _searchedQuery != q) return;
        setState(() {
          _loading = false;
          _results = [];
          _error = e is OpenFoodFactsException ? e.message : '$e';
        });
      },
      onDone: () {
        if (!mounted || _searchedQuery != q) return;
        if (_loading) setState(() => _loading = false);
      },
    );
  }

  Future<void> _scanBarcode() async {
    final l10n = context.l10n;
    final unlocked = await AdService.instance.isScannerUnlockedToday();
    if (!mounted) return;

    if (!unlocked) {
      final watch = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.unlockScannerTitle),
          content: Text(l10n.unlockScannerBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
              label: Text(l10n.watchAd),
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
        setState(() => _error = l10n.adUnavailable);
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
      final item = await FoodSearchService.instance.lookupBarcode(barcode);
      if (!mounted) return;
      setState(() => _loading = false);
      if (item == null) {
        setState(() => _error = context.l10n.productNotFound);
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

  void _addAsCustomFood() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CreateCustomFoodScreen(
        defaultMeal: widget.defaultMeal,
        initialName: _query,
      ),
    ));
  }

  Future<void> _quickAdd() async {
    final kcal = await showQuickAddSheet(context,
        defaultMeal: widget.defaultMeal, initialName: _query);
    if (kcal == null || !mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final l10n = context.l10n;
    final tabs = widget.pickMode
        ? [Tab(text: l10n.tabSearch), Tab(text: l10n.tabMyFoods)]
        : [
            Tab(text: l10n.tabSearch),
            Tab(text: l10n.tabRecentFav),
            Tab(text: l10n.tabRecipes),
          ];

    return Scaffold(
      // Reading screen: search results, not a logging decision. The bottom
      // bar keeps the list above it.
      bottomNavigationBar: AdBanner.bar(),
      appBar: AppBar(
        title: Text(widget.pickMode ? l10n.pickIngredientTitle : l10n.addFoodTitle),
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
                          hintText: l10n.searchHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _onQueryChanged('');
                                  })
                              : null,
                        ),
                        onChanged: _onQueryChanged,
                      ),
                    ),
                    // Scanning is available everywhere, including when picking a
                    // recipe ingredient (pickMode) — a scanned item is returned
                    // to the recipe builder just like a searched one.
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceAlt),
                      icon: const Icon(Icons.qr_code_scanner_rounded,
                          color: AppColors.accent),
                      tooltip: l10n.scanTooltip,
                      onPressed: _scanBarcode,
                    ),
                  ],
                ),
              ),
              Expanded(child: _searchBody(store, l10n)),
            ],
          ),

          // ── Recent & Favourites / My Foods tab ──────────────────────────────
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: Text(l10n.createCustomFood),
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
                _sectionHeader(l10n.tabMyFoods),
                for (final item in store.customFoods)
                  _FoodTile(item: item, onTap: _handleItem),
              ],
              // Favourites & recents are shown in both modes — when building a
              // recipe you can pull ingredients straight from your saved foods.
              if (store.favourites.isNotEmpty) ...[
                _sectionHeader(l10n.sectionFavourites),
                for (final item in store.favourites)
                  _FoodTile(item: item, onTap: _handleItem),
              ],
              if (store.recents.isNotEmpty) ...[
                _sectionHeader(l10n.sectionRecent),
                for (final item in store.recents)
                  _FoodTile(item: item, onTap: _handleItem),
              ],
              if (store.customFoods.isEmpty &&
                  store.favourites.isEmpty &&
                  store.recents.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Text(l10n.noFoodsYet,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted)),
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

  /// Everything under the search field.
  ///
  /// Before typing: the foods logged most recently, because the next meal is
  /// usually a repeat. While typing: the user's own matching foods, then the
  /// live list — with a cached list standing in while a slow mirror answers,
  /// a retry when nothing answers, and two ways to log a food that was never
  /// going to be found. There is no state that renders as an empty list.
  Widget _searchBody(FoodStore store, AppLocalizations l10n) {
    final q = _query;

    if (q.isEmpty) {
      final recents = store.recents;
      if (recents.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Text(l10n.searchEmptyPrompt,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted)),
        );
      }
      return ListView(
        children: [
          _sectionHeader(l10n.sectionRecent),
          for (final item in recents) _FoodTile(item: item, onTap: _handleItem),
        ],
      );
    }

    final local = store.localMatches(q);
    final showingSearched = _searchedQuery == q;
    final children = <Widget>[
      if (local.isNotEmpty) ...[
        _sectionHeader(l10n.sectionYourFoods),
        for (final item in local) _FoodTile(item: item, onTap: _handleItem),
      ],
      _sectionHeader(l10n.sectionOpenFoodFacts,
          trailing: showingSearched && _fromCache
              ? _CachedChip(
                  label: _offline
                      ? l10n.searchOfflineCached
                      : l10n.searchCachedLabel)
              : null),
    ];

    if (!showingSearched) {
      // Debounce window, or a one-character query: nothing has been asked yet.
      children.add(Padding(
        padding: const EdgeInsets.all(24),
        child: Text(l10n.searchTypeMore,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
      ));
    } else if (_error != null) {
      children.add(_RetryBlock(message: _error!, onRetry: () => _search(q)));
    } else if (_results.isEmpty && !_loading) {
      children.add(_NoMatchBlock(
        query: q,
        onCustom: _addAsCustomFood,
        onQuickAdd: widget.pickMode ? null : _quickAdd,
      ));
    } else {
      if (_loading && _results.isEmpty) {
        children.add(const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ));
      }
      if (_loading && _results.isNotEmpty) {
        children.add(const LinearProgressIndicator(minHeight: 2));
      }
      for (final item in _results) {
        children.add(_FoodTile(item: item, onTap: _handleItem));
      }
      if (!_loading && _results.isNotEmpty) {
        // The last row is always a way out for the food that was not there.
        children.add(_NotThereFooter(
          onCustom: _addAsCustomFood,
          onQuickAdd: widget.pickMode ? null : _quickAdd,
        ));
      }
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: children,
    );
  }

  Widget _sectionHeader(String label, {Widget? trailing}) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
            ),
            ?trailing,
          ],
        ),
      );
}

class _CachedChip extends StatelessWidget {
  const _CachedChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.offline_bolt_outlined,
              size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

/// A failed live search with no cache to fall back on. Says what went wrong
/// and offers to try again — never a blank list.
class _RetryBlock extends StatelessWidget {
  const _RetryBlock({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded,
              color: AppColors.textMuted, size: 28),
          const SizedBox(height: 10),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.retry),
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// The search came back empty. Two ways forward, both of which end with the
/// food in the log.
class _NoMatchBlock extends StatelessWidget {
  const _NoMatchBlock({
    required this.query,
    required this.onCustom,
    this.onQuickAdd,
  });
  final String query;
  final VoidCallback onCustom;
  final VoidCallback? onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.noMatchFor(query),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text(l10n.noMatchHint,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
            label: Text(l10n.addAsCustomFood),
            onPressed: onCustom,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
          if (onQuickAdd != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: Text(l10n.quickAddCalories),
              onPressed: onQuickAdd,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Below a non-empty result list: the same two actions, quieter.
class _NotThereFooter extends StatelessWidget {
  const _NotThereFooter({required this.onCustom, this.onQuickAdd});
  final VoidCallback onCustom;
  final VoidCallback? onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
            label: Text(l10n.addAsCustomFood),
            onPressed: onCustom,
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
          if (onQuickAdd != null)
            TextButton.icon(
              icon: const Icon(Icons.bolt_rounded, size: 16),
              label: Text(l10n.quickAddCalories),
              onPressed: onQuickAdd,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
        ],
      ),
    );
  }
}

// ── Recipes tab ─────────────────────────────────────────────────────────────

class _RecipesTab extends StatelessWidget {
  const _RecipesTab({required this.defaultMeal});
  final MealType defaultMeal;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final l10n = context.l10n;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.restaurant_menu_rounded, size: 18),
            label: Text(l10n.createNewRecipe),
            onPressed: () => Navigator.of(context)
                .push(CreateRecipeScreen.route()),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        if (store.recipes.isEmpty)
          Padding(
            padding: const EdgeInsets.all(48),
            child: Text(l10n.noRecipesYet,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted)),
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
    final l10n = context.l10n;
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
        l10n.recipePerServing(
            recipe.caloriesPerServing.round(), recipe.servings),
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
        itemBuilder: (_) => [
          PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
          PopupMenuItem(
              value: 'delete',
              child: Text(l10n.delete,
                  style: const TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  Future<void> _logDialog(BuildContext context, FoodStore store) async {
    final l10n = context.l10n;
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
                l10n.recipeKcalPerServing(recipe.caloriesPerServing.round()),
                style:
                    const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: servCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: l10n.servingsToLog),
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
                        child: Text(m.localizedLabel(l10n))))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
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
              child: Text(l10n.logAction),
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
        builder: (_, store, _) => IconButton(
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
              ? context.l10n.removeFavourite
              : context.l10n.addToFavourites,
        ),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
