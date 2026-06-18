import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food_entry.dart';
import '../../models/food_item.dart';
import '../../services/food_store.dart';
import '../../services/openfoodfacts_service.dart';
import '../../theme/app_colors.dart';
import 'barcode_screen.dart';
import 'food_detail_screen.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key, required this.defaultMeal});
  final MealType defaultMeal;

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: 2, vsync: this);

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
    final items = await OpenFoodFactsService.instance.search(query.trim());
    if (!mounted) return;
    setState(() {
      _loading = false;
      _results = items;
      if (items.isEmpty) _error = 'No results found for "$query".';
    });
  }

  Future<void> _scanBarcode() async {
    final barcode = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const BarcodeScreen()));
    if (barcode == null || !mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final item = await OpenFoodFactsService.instance.fetchByBarcode(barcode);
    if (!mounted) return;
    setState(() => _loading = false);
    if (item == null) {
      setState(() => _error = 'Product not found in database.');
      return;
    }
    _openDetail(item);
  }

  void _openDetail(FoodItem item) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            FoodDetailScreen(item: item, defaultMeal: widget.defaultMeal)));
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FoodStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add food'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Search'),
            Tab(text: 'Recent & Favourites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── Search tab ──
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
                    separatorBuilder: (context, index) => const Divider(
                        height: 1, color: AppColors.border),
                    itemBuilder: (_, i) =>
                        _FoodTile(item: _results[i], onTap: _openDetail),
                  ),
                ),
            ],
          ),

          // ── Recent & Favourites tab ──
          ListView(
            children: [
              if (store.favourites.isNotEmpty) ...[
                _sectionHeader('Favourites ⭐'),
                for (final item in store.favourites)
                  _FoodTile(item: item, onTap: _openDetail),
              ],
              if (store.recents.isNotEmpty) ...[
                _sectionHeader('Recent'),
                for (final item in store.recents)
                  _FoodTile(item: item, onTap: _openDetail),
              ],
              if (store.favourites.isEmpty && store.recents.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(48),
                  child: Text('No recent foods yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted)),
                ),
            ],
          ),
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
        item.brand.isNotEmpty ? item.brand : 'per 100 g',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: Text(
        '${item.caloriesPer100.round()} kcal / 100 g',
        style: const TextStyle(
            color: AppColors.calories,
            fontSize: 12,
            fontWeight: FontWeight.w600),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
