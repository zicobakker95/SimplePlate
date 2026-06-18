import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/nutrition_goals.dart';
import '../../services/food_store.dart';
import '../../theme/app_colors.dart';
import '../home/home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  // Goal inputs
  int _calories = 2000;
  int _protein = 150;
  int _carbs = 200;
  int _fat = 65;

  void _next() {
    if (_page < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final store = context.read<FoodStore>();
    await store.saveGoals(NutritionGoals(
      dailyCalories: _calories,
      proteinGrams: _protein,
      carbsGrams: _carbs,
      fatGrams: _fat,
    ));
    await store.markOnboardingDone();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(onNext: _next),
                  _GoalsPage(
                    calories: _calories,
                    protein: _protein,
                    carbs: _carbs,
                    fat: _fat,
                    onChanged: (c, p, carbs, f) => setState(() {
                      _calories = c;
                      _protein = p;
                      _carbs = carbs;
                      _fat = f;
                    }),
                    onNext: _next,
                  ),
                  _PermissionsPage(onFinish: _finish),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.restaurant_menu_rounded,
                color: Colors.white, size: 52),
          ),
          const SizedBox(height: 32),
          Text('Welcome to PlateSimple',
              style: tt.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            'Fast, clean calorie tracking.\nFree barcode scanning. No clutter.',
            style: tt.bodyLarge
                ?.copyWith(color: AppColors.textSecondary, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: onNext, child: const Text('Get started')),
          ),
        ],
      ),
    );
  }
}

class _GoalsPage extends StatefulWidget {
  const _GoalsPage({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.onChanged,
    required this.onNext,
  });
  final int calories, protein, carbs, fat;
  final void Function(int c, int p, int carbs, int f) onChanged;
  final VoidCallback onNext;

  @override
  State<_GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<_GoalsPage> {
  late final _calCtrl =
      TextEditingController(text: widget.calories.toString());
  late final _proCtrl =
      TextEditingController(text: widget.protein.toString());
  late final _carbCtrl =
      TextEditingController(text: widget.carbs.toString());
  late final _fatCtrl = TextEditingController(text: widget.fat.toString());

  void _notify() {
    widget.onChanged(
      int.tryParse(_calCtrl.text) ?? widget.calories,
      int.tryParse(_proCtrl.text) ?? widget.protein,
      int.tryParse(_carbCtrl.text) ?? widget.carbs,
      int.tryParse(_fatCtrl.text) ?? widget.fat,
    );
  }

  @override
  void dispose() {
    _calCtrl.dispose();
    _proCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  Widget _field(String label, TextEditingController ctrl, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        onChanged: (_) => _notify(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: accent),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accent, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('Set your daily goals',
              style:
                  tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('You can change these anytime in Goals.',
              style: tt.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          _field('Calories (kcal)', _calCtrl, AppColors.calories),
          _field('Protein (g)', _proCtrl, AppColors.protein),
          _field('Carbs (g)', _carbCtrl, AppColors.carbs),
          _field('Fat (g)', _fatCtrl, AppColors.fat),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: widget.onNext, child: const Text('Continue')),
          ),
        ],
      ),
    );
  }
}

class _PermissionsPage extends StatelessWidget {
  const _PermissionsPage({required this.onFinish});
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_active_rounded,
              size: 72, color: AppColors.primary),
          const SizedBox(height: 32),
          Text('Stay on track',
              style: tt.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Text(
            'Allow notifications so we can remind you to log meals and keep your streak alive.',
            style: tt.bodyLarge
                ?.copyWith(color: AppColors.textSecondary, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: onFinish,
                child: const Text("Let's go!")),
          ),
          const SizedBox(height: 12),
          TextButton(
              onPressed: onFinish, child: const Text('Skip for now')),
        ],
      ),
    );
  }
}
