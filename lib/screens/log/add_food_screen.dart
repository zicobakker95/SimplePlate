import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/food_entry.dart';
import '../../models/food_item.dart';
import '../../models/recipe.dart';
import '../../services/ad_config.dart';
import '../../services/ad_service.dart';
import '../../services/food_search_service.dart';
import '../../services/food_store.dart';
import '../../services/openfoodfacts_service.dart';
import '../../ui/kit.dart';
import '../../widgets/ad_banner.dart';
import '../../widgets/quick_add_sheet.dart';
import '../../widgets/rewarded_unlock.dart';
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
  late final TabController _tabs = TabController(
    length: widget.pickMode ? 2 : 3,
    vsync: this,
  );

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

    final locale = Localizations.localeOf(context);
    await _sub?.cancel();
    if (!mounted) return;
    setState(() {
      _searchedQuery = q;
      _loading = true;
      _error = null;
      _fromCache = false;
      _offline = false;
    });
    _sub = FoodSearchService.instance
        .search(q, locale: locale)
        .listen(
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
        builder: (ctx) => PtDialog(
          title: l10n.unlockScannerTitle,
          body: l10n.unlockScannerBody,
          icon: Icons.qr_code_scanner_rounded,
          actions: [
            PtButton(
              label: l10n.cancel,
              tone: PtButtonTone.ghost,
              compact: true,
              onPressed: () => Navigator.pop(ctx, false),
            ),
            PtButton(
              label: l10n.watchAd,
              icon: Icons.play_circle_outline_rounded,
              compact: true,
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      );
      if (watch != true || !mounted) return;

      // Unlocks only on the ad's reward; with no ad it explains and offers
      // a retry or Premium (see unlockWithRewardedAd).
      final unlocked = await unlockWithRewardedAd(
        context,
        key: AdService.scannerUnlockKey,
        days: AdConfig.instance.scannerUnlockDays,
        placement: 'barcode_scanner',
      );
      if (!unlocked || !mounted) return;
    }

    if (!mounted) return;
    final barcode = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const BarcodeScreen()));
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
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              FoodDetailScreen(item: item, defaultMeal: widget.defaultMeal),
        ),
      );
    }
  }

  void _addAsCustomFood() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateCustomFoodScreen(
          defaultMeal: widget.defaultMeal,
          initialName: _query,
        ),
      ),
    );
  }

  Future<void> _quickAdd() async {
    final kcal = await showQuickAddSheet(
      context,
      defaultMeal: widget.defaultMeal,
      initialName: _query,
    );
    if (kcal == null || !mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();
    final l10n = context.l10n;
    final p = context.pal;
    Tab tab(String label) => Tab(
      child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
    );
    final tabs = widget.pickMode
        ? [tab(l10n.tabSearch), tab(l10n.tabMyFoods)]
        : [tab(l10n.tabSearch), tab(l10n.tabRecentFav), tab(l10n.tabRecipes)];

    return Scaffold(
      // Reading screen: search results, not a logging decision. The bottom
      // bar keeps the list above it.
      bottomNavigationBar: AdBanner.bar(),
      appBar: AppBar(
        title: Text(
          widget.pickMode ? l10n.pickIngredientTitle : l10n.addFoodTitle,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              height: 46,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: p.sunken,
                borderRadius: BorderRadius.circular(Pt.rPill),
              ),
              child: TabBar(
                controller: _tabs,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: p.isDark ? p.surfaceAlt : p.surface,
                  borderRadius: BorderRadius.circular(Pt.rPill),
                  boxShadow: Pt.shadow(p, 0.4),
                ),
                labelColor: p.text,
                unselectedLabelColor: p.textMuted,
                labelStyle: PtText.small(weight: FontWeight.w700),
                unselectedLabelStyle: PtText.small(weight: FontWeight.w500),
                splashFactory: NoSplash.splashFactory,
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                tabs: tabs,
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── Search tab ──────────────────────────────────────────────────
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
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
                                  icon: const Icon(Icons.close_rounded),
                                  tooltip: MaterialLocalizations.of(
                                    context,
                                  ).deleteButtonTooltip,
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _onQueryChanged('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: _onQueryChanged,
                      ),
                    ),
                    // Scanning is available everywhere, including when picking
                    // a recipe ingredient (pickMode) — a scanned item is
                    // returned to the recipe builder just like a searched one.
                    PtIconButton(
                      icon: Icons.qr_code_scanner_rounded,
                      tooltip: l10n.scanTooltip,
                      background: p.primarySoft,
                      color: p.primary,
                      onPressed: _scanBarcode,
                    ),
                  ],
                ),
              ),
              Expanded(child: _searchBody(store, l10n)),
            ],
          ),

          // ── Recent & Favourites / My Foods tab ──────────────────────────
          ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: PtButton(
                  label: l10n.createCustomFood,
                  icon: Icons.add_circle_outline_rounded,
                  tone: PtButtonTone.soft,
                  expand: true,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateCustomFoodScreen(
                        defaultMeal: widget.defaultMeal,
                      ),
                    ),
                  ),
                ),
              ),
              if (store.customFoods.isNotEmpty)
                _FoodGroup(
                  title: l10n.tabMyFoods,
                  items: store.customFoods,
                  onTap: _handleItem,
                ),
              // Favourites & recents are shown in both modes — when building
              // a recipe you can pull ingredients straight from saved foods.
              if (store.favourites.isNotEmpty)
                _FoodGroup(
                  title: l10n.sectionFavourites,
                  items: store.favourites,
                  onTap: _handleItem,
                ),
              if (store.recents.isNotEmpty)
                _FoodGroup(
                  title: l10n.sectionRecent,
                  items: store.recents,
                  onTap: _handleItem,
                ),
              if (store.customFoods.isEmpty &&
                  store.favourites.isEmpty &&
                  store.recents.isEmpty)
                PtEmptyState(mood: SproutMood.sleepy, title: l10n.noFoodsYet),
            ],
          ),

          // ── Recipes tab (normal mode only) ──────────────────────────────
          if (!widget.pickMode) _RecipesTab(defaultMeal: widget.defaultMeal),
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
    final p = context.pal;

    if (q.isEmpty) {
      final recents = store.recents;
      if (recents.isEmpty) {
        return SingleChildScrollView(
          child: PtEmptyState(
            mood: SproutMood.hungry,
            title: l10n.searchStartTitle,
            body: l10n.searchEmptyPrompt,
          ),
        );
      }
      return ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _FoodGroup(
            title: l10n.sectionRecent,
            items: recents,
            onTap: _handleItem,
          ),
        ],
      );
    }

    final local = store.localMatches(q);
    final showingSearched = _searchedQuery == q;
    final children = <Widget>[
      if (local.isNotEmpty)
        _FoodGroup(
          title: l10n.sectionYourFoods,
          items: local,
          onTap: _handleItem,
        ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: PtSectionHeader(
          l10n.sectionOpenFoodFacts,
          trailing: showingSearched && _fromCache
              ? PtTag(
                  label: _offline
                      ? l10n.searchOfflineCached
                      : l10n.searchCachedLabel,
                  color: p.textMuted,
                  icon: Icons.offline_bolt_outlined,
                )
              : null,
        ),
      ),
    ];

    if (!showingSearched) {
      // Debounce window, or a one-character query: nothing has been asked.
      children.add(
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.searchTypeMore,
            textAlign: TextAlign.center,
            style: PtText.small(color: p.textMuted),
          ),
        ),
      );
    } else if (_error != null) {
      children.add(
        PtEmptyState(
          mood: SproutMood.thinking,
          title: _error!,
          action: PtButton(
            label: l10n.retry,
            icon: Icons.refresh_rounded,
            tone: PtButtonTone.soft,
            onPressed: () => _search(q),
          ),
        ),
      );
    } else if (_results.isEmpty && !_loading) {
      children.add(
        _NoMatchBlock(
          query: q,
          onCustom: _addAsCustomFood,
          onQuickAdd: widget.pickMode ? null : _quickAdd,
        ),
      );
    } else {
      if (_loading && _results.isEmpty) {
        children.add(const PtSkeletonList());
      }
      if (_loading && _results.isNotEmpty) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(minHeight: 3),
          ),
        );
      }
      if (_results.isNotEmpty) {
        children.add(_FoodGroup(items: _results, onTap: _handleItem));
      }
      if (!_loading && _results.isNotEmpty) {
        // The last row is always a way out for the food that was not there.
        children.add(
          _NotThereFooter(
            onCustom: _addAsCustomFood,
            onQuickAdd: widget.pickMode ? null : _quickAdd,
          ),
        );
      }
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 24),
      children: children,
    );
  }
}

/// A titled card of food rows that fade in one after another.
class _FoodGroup extends StatelessWidget {
  const _FoodGroup({this.title, required this.items, required this.onTap});

  final String? title;
  final List<FoodItem> items;
  final void Function(FoodItem) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) PtSectionHeader(title!),
          if (title == null) const SizedBox(height: 4),
          PtCard(
            padding: EdgeInsets.zero,
            clip: true,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const PtDivider(indent: 70),
                  FadeSlideIn(
                    key: ValueKey(items[i].id),
                    index: i,
                    offset: 10,
                    child: _FoodTile(item: items[i], onTap: onTap),
                  ),
                ],
              ],
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
    return PtEmptyState(
      mood: SproutMood.hungry,
      title: l10n.noMatchFor(query),
      body: l10n.noMatchHint,
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PtButton(
            label: l10n.addAsCustomFood,
            icon: Icons.add_circle_outline_rounded,
            expand: true,
            onPressed: onCustom,
          ),
          if (onQuickAdd != null) ...[
            const SizedBox(height: 8),
            PtButton(
              label: l10n.quickAddCalories,
              icon: Icons.bolt_rounded,
              tone: PtButtonTone.soft,
              expand: true,
              onPressed: onQuickAdd,
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          PtButton(
            label: l10n.addAsCustomFood,
            icon: Icons.add_circle_outline_rounded,
            tone: PtButtonTone.ghost,
            compact: true,
            onPressed: onCustom,
          ),
          if (onQuickAdd != null)
            PtButton(
              label: l10n.quickAddCalories,
              icon: Icons.bolt_rounded,
              tone: PtButtonTone.ghost,
              compact: true,
              onPressed: onQuickAdd,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        PtButton(
          label: l10n.createNewRecipe,
          icon: Icons.restaurant_menu_rounded,
          tone: PtButtonTone.soft,
          expand: true,
          onPressed: () =>
              Navigator.of(context).push(CreateRecipeScreen.route()),
        ),
        const SizedBox(height: 12),
        if (store.recipes.isEmpty)
          PtEmptyState(mood: SproutMood.sleepy, title: l10n.noRecipesYet),
        for (var i = 0; i < store.recipes.length; i++)
          FadeSlideIn(
            key: ValueKey(store.recipes[i].id),
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RecipeTile(
                recipe: store.recipes[i],
                defaultMeal: defaultMeal,
              ),
            ),
          ),
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
    final p = context.pal;
    return PtCard(
      padding: EdgeInsets.zero,
      child: PtTile(
        onTap: () => _logDialog(context, store),
        leading: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.honeySoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text('🍲', style: TextStyle(fontSize: 22)),
        ),
        title: recipe.name,
        titleStyle: PtText.tile(
          color: p.text,
        ).copyWith(fontWeight: FontWeight.w600),
        subtitle: l10n.recipePerServing(
          recipe.caloriesPerServing.round(),
          recipe.servings,
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: p.textMuted),
          tooltip: MaterialLocalizations.of(context).showMenuTooltip,
          onSelected: (v) {
            if (v == 'edit') {
              Navigator.of(
                context,
              ).push(CreateRecipeScreen.route(existing: recipe));
            } else if (v == 'delete') {
              store.deleteRecipe(recipe.id);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
            PopupMenuItem(
              value: 'delete',
              child: Text(l10n.delete, style: TextStyle(color: p.dangerInk)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logDialog(BuildContext context, FoodStore store) async {
    final l10n = context.l10n;
    final servCtrl = TextEditingController(text: '1');
    MealType meal = defaultMeal;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => PtDialog(
          title: recipe.name,
          body: l10n.recipeKcalPerServing(recipe.caloriesPerServing.round()),
          icon: Icons.restaurant_menu_rounded,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: servCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.servingsToLog),
                onChanged: (_) => setS(() {}),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in MealType.values)
                    PtChoiceChip(
                      label: m.localizedLabel(l10n),
                      leading: m.emoji,
                      selected: meal == m,
                      onTap: () => setS(() => meal = m),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            PtButton(
              label: l10n.cancel,
              tone: PtButtonTone.ghost,
              compact: true,
              onPressed: () => Navigator.pop(ctx),
            ),
            PtButton(
              label: l10n.logAction,
              icon: Icons.check_rounded,
              compact: true,
              haptic: true,
              onPressed: () async {
                final s = int.tryParse(servCtrl.text) ?? 1;
                Navigator.pop(ctx);
                await store.logRecipe(recipe, s, meal);
                if (context.mounted) Navigator.of(context).pop();
              },
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
    final p = context.pal;
    return PtTile(
      onTap: () => onTap(item),
      padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
      leading: MacroSplitRing(
        protein: item.proteinPer100,
        carbs: item.carbsPer100,
        fat: item.fatPer100,
        size: 42,
      ),
      title: item.name,
      titleMaxLines: 1,
      subtitle: item.brand.isNotEmpty
          ? '${item.brand}  ·  ${item.caloriesPer100.round()} kcal/100g'
          : '${item.caloriesPer100.round()} kcal / 100 g',
      subtitleMaxLines: 1,
      trailing: Consumer<FoodStore>(
        builder: (_, store, _) {
          final fav = store.isFavourite(item.id);
          return Bump(
            trigger: fav,
            child: PtIconButton(
              icon: fav ? Icons.star_rounded : Icons.star_border_rounded,
              tooltip: fav
                  ? context.l10n.removeFavourite
                  : context.l10n.addToFavourites,
              background: Colors.transparent,
              color: fav ? p.honey : p.textFaint,
              size: 40,
              iconSize: 24,
              onPressed: () => store.toggleFavourite(item),
            ),
          );
        },
      ),
    );
  }
}
