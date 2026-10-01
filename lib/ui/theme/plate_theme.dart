import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// PlateSimple design tokens: the "kitchen table" palette.
///
/// Light is the hero look (linen tablecloth, plate-white cards, herb green);
/// dark is the same kitchen at night (warm espresso, brightened food colours).
/// Read the active palette with `context.pal`.
@immutable
class PlatePalette extends ThemeExtension<PlatePalette> {
  const PlatePalette({
    required this.brightness,
    required this.bg,
    required this.bgDeep,
    required this.surface,
    required this.surfaceAlt,
    required this.sunken,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.primary,
    required this.primarySoft,
    required this.onPrimary,
    required this.fresh,
    required this.freshSoft,
    required this.protein,
    required this.proteinInk,
    required this.carbs,
    required this.carbsInk,
    required this.fat,
    required this.fatInk,
    required this.honey,
    required this.honeyInk,
    required this.honeySoft,
    required this.water,
    required this.waterSoft,
    required this.danger,
    required this.dangerInk,
    required this.dangerSoft,
    required this.premium,
    required this.premiumInk,
    required this.premiumSoft,
    required this.shadow,
    required this.plate,
    required this.plateRim,
    required this.sproutBody,
    required this.sproutDeep,
    required this.sproutLeaf,
    required this.sproutCheek,
    required this.sproutFace,
  });

  final Brightness brightness;

  /// Scaffold (linen) and a deeper wash for headers.
  final Color bg;
  final Color bgDeep;

  /// Cards and sheets (plate white), raised rows, recessed tracks/inputs.
  final Color surface;
  final Color surfaceAlt;
  final Color sunken;
  final Color border;

  final Color text;
  final Color textMuted;

  /// Decorative only (disabled glyphs, placeholders); never body copy.
  final Color textFaint;

  /// Herb green: buttons, links, the calorie colour.
  final Color primary;
  final Color primarySoft;
  final Color onPrimary;

  /// Bright leaf green for fills (rings, bars, success).
  final Color fresh;
  final Color freshSoft;

  /// Macro colours from the app icon. `*Ink` variants are for text on
  /// surfaces (contrast >= 4.5:1); the plain ones are for fills.
  final Color protein;
  final Color proteinInk;
  final Color carbs;
  final Color carbsInk;
  final Color fat;
  final Color fatInk;

  /// Streaks, stars, favourites.
  final Color honey;
  final Color honeyInk;
  final Color honeySoft;

  final Color water;
  final Color waterSoft;

  /// Over target, delete.
  final Color danger;
  final Color dangerInk;
  final Color dangerSoft;

  /// Premium (saffron).
  final Color premium;
  final Color premiumInk;
  final Color premiumSoft;

  final Color shadow;

  /// The plate in the middle of the calorie ring.
  final Color plate;
  final Color plateRim;

  /// Sprout, the mascot.
  final Color sproutBody;
  final Color sproutDeep;
  final Color sproutLeaf;
  final Color sproutCheek;
  final Color sproutFace;

  bool get isDark => brightness == Brightness.dark;

  static const light = PlatePalette(
    brightness: Brightness.light,
    bg: Color(0xFFF6F1E7),
    bgDeep: Color(0xFFEDE5D4),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFFBF8F2),
    sunken: Color(0xFFEFE8DB),
    border: Color(0xFFE6DDCC),
    text: Color(0xFF2B2620),
    textMuted: Color(0xFF6B6357),
    textFaint: Color(0xFF9A9183),
    primary: Color(0xFF1E7D4A),
    primarySoft: Color(0xFFDDF1E3),
    onPrimary: Color(0xFFFFFFFF),
    fresh: Color(0xFF3DB873),
    freshSoft: Color(0xFFE3F5E9),
    protein: Color(0xFF3F8FD6),
    proteinInk: Color(0xFF1E6FB8),
    carbs: Color(0xFFE8962A),
    carbsInk: Color(0xFF9C5E0C),
    fat: Color(0xFFE2604E),
    fatInk: Color(0xFFC2412F),
    honey: Color(0xFFF2A93B),
    honeyInk: Color(0xFF9C5E0C),
    honeySoft: Color(0xFFFDF0D8),
    water: Color(0xFF3BA8E0),
    waterSoft: Color(0xFFE0F2FB),
    danger: Color(0xFFE0533F),
    dangerInk: Color(0xFFC2412F),
    dangerSoft: Color(0xFFFBE4DF),
    premium: Color(0xFFD99A2B),
    premiumInk: Color(0xFF94650F),
    premiumSoft: Color(0xFFFBEFD7),
    shadow: Color(0x175A4320),
    plate: Color(0xFFFFFFFF),
    plateRim: Color(0xFFEFE8DB),
    sproutBody: Color(0xFF6CCB7E),
    sproutDeep: Color(0xFF3FA45A),
    sproutLeaf: Color(0xFF2E9150),
    sproutCheek: Color(0xFFF29A8A),
    sproutFace: Color(0xFF2B2620),
  );

  static const dark = PlatePalette(
    brightness: Brightness.dark,
    bg: Color(0xFF15130F),
    bgDeep: Color(0xFF1D1A15),
    surface: Color(0xFF211E19),
    surfaceAlt: Color(0xFF29251F),
    sunken: Color(0xFF1A1814),
    border: Color(0xFF363026),
    text: Color(0xFFF4EFE6),
    textMuted: Color(0xFFB5AB9B),
    textFaint: Color(0xFF7D7466),
    primary: Color(0xFF4CC487),
    primarySoft: Color(0xFF1C3526),
    onPrimary: Color(0xFF0E1F15),
    fresh: Color(0xFF5AD094),
    freshSoft: Color(0xFF1C3526),
    protein: Color(0xFF6AB0F0),
    proteinInk: Color(0xFF6AB0F0),
    carbs: Color(0xFFF4B04E),
    carbsInk: Color(0xFFF4B04E),
    fat: Color(0xFFF27F6D),
    fatInk: Color(0xFFF27F6D),
    honey: Color(0xFFF7BC55),
    honeyInk: Color(0xFFF7BC55),
    honeySoft: Color(0xFF3A2E17),
    water: Color(0xFF5CC0F2),
    waterSoft: Color(0xFF15303D),
    danger: Color(0xFFF2735F),
    dangerInk: Color(0xFFF2735F),
    dangerSoft: Color(0xFF3D1E19),
    premium: Color(0xFFE6A94A),
    premiumInk: Color(0xFFE6A94A),
    premiumSoft: Color(0xFF3A2E17),
    shadow: Color(0x66000000),
    plate: Color(0xFF2C2822),
    plateRim: Color(0xFF221F1A),
    sproutBody: Color(0xFF6CCB7E),
    sproutDeep: Color(0xFF3FA45A),
    sproutLeaf: Color(0xFF4CB86C),
    sproutCheek: Color(0xFFF29A8A),
    sproutFace: Color(0xFF1A1814),
  );

  @override
  PlatePalette copyWith() => this;

  /// Palettes swap rather than blend: a half-light, half-dark frame during
  /// the theme animation looks muddy for food colours.
  @override
  PlatePalette lerp(covariant PlatePalette? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

/// Spacing, radii, motion and shadows.
class Pt {
  Pt._();

  static const double s4 = 4, s8 = 8, s12 = 12, s16 = 16, s20 = 20, s24 = 24;
  static const double s32 = 32, s40 = 40;

  /// Horizontal page gutter.
  static const double gutter = 20;

  static const double rSm = 12, rMd = 18, rLg = 26, rPill = 999;

  /// Minimum tap target.
  static const double tap = 48;

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration fill = Duration(milliseconds: 900);
  static const Curve ease = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;

  /// Soft warm two-layer elevation (light); dark relies on borders instead.
  static List<BoxShadow> shadow(PlatePalette p, [double strength = 1]) {
    if (p.isDark) return const [];
    return [
      BoxShadow(
        color: p.shadow.withValues(alpha: p.shadow.a * strength),
        blurRadius: 18 * strength,
        offset: Offset(0, 5 * strength),
      ),
      BoxShadow(
        color: p.shadow.withValues(alpha: p.shadow.a * 0.5 * strength),
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static LinearGradient primaryGradient(PlatePalette p) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [p.fresh, p.primary],
  );

  static LinearGradient premiumGradient(PlatePalette p) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [const Color(0xFFF7C66B), p.premium],
  );
}

/// Type scale (Rubik, bundled). Styles leave colour null unless given, so
/// text inherits the surrounding default (body text colour).
class PtText {
  PtText._();

  static const String family = 'Rubik';

  /// Screenshot tests only: extra families (an emoji face) for glyphs Rubik
  /// lacks. On devices the platform's own fallback handles them.
  static List<String>? debugFontFallback;

  static const _tabular = [FontFeature.tabularFigures()];

  static TextStyle display({Color? color}) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: debugFontFallback,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.6,
    color: color,
  );
  static TextStyle title({Color? color}) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: debugFontFallback,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
    color: color,
  );
  static TextStyle headline({Color? color}) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: debugFontFallback,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: color,
  );
  static TextStyle tile({Color? color}) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: debugFontFallback,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.25,
    color: color,
  );
  static TextStyle body({Color? color, FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: family,
        fontFamilyFallback: debugFontFallback,
        fontSize: 15,
        fontWeight: weight,
        height: 1.4,
        color: color,
      );
  static TextStyle small({Color? color, FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: family,
        fontFamilyFallback: debugFontFallback,
        fontSize: 13,
        fontWeight: weight,
        height: 1.35,
        color: color,
      );
  static TextStyle tiny({Color? color, FontWeight weight = FontWeight.w500}) =>
      TextStyle(
        fontFamily: family,
        fontFamilyFallback: debugFontFallback,
        fontSize: 11.5,
        fontWeight: weight,
        height: 1.3,
        color: color,
      );
  static TextStyle label({Color? color}) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: debugFontFallback,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: color,
  );
  static TextStyle button({Color? color}) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: debugFontFallback,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    color: color,
  );
  static TextStyle number(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w700,
  }) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: debugFontFallback,
    fontSize: size,
    fontWeight: weight,
    height: 1.05,
    letterSpacing: size > 24 ? -0.8 : 0,
    color: color,
    fontFeatures: _tabular,
  );
}

extension PlateContext on BuildContext {
  PlatePalette get pal =>
      Theme.of(this).extension<PlatePalette>() ?? PlatePalette.dark;

  /// The OS "remove animations" setting: entrances, confetti and count-ups
  /// become instant state changes.
  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;
}

/// Fade + small rise for pushed screens. iOS keeps its native swipe-back.
class PtPageTransitionsBuilder extends PageTransitionsBuilder {
  const PtPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (context.reduceMotion) return child;
    final a = CurvedAnimation(
      parent: animation,
      curve: Pt.ease,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(a),
        child: child,
      ),
    );
  }
}

/// Material theme built from the tokens, so stock widgets (time picker,
/// switches, text fields, menus, snackbars) match the custom ones.
ThemeData buildPlateTheme(Brightness brightness) {
  final p = brightness == Brightness.dark
      ? PlatePalette.dark
      : PlatePalette.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: p.primary,
    brightness: brightness,
    primary: p.primary,
    onPrimary: p.onPrimary,
    secondary: p.carbs,
    error: p.danger,
    surface: p.surface,
    onSurface: p.text,
    onSurfaceVariant: p.textMuted,
    outline: p.border,
    outlineVariant: p.border,
    surfaceContainerHighest: p.sunken,
    surfaceContainerHigh: p.surfaceAlt,
    surfaceContainer: p.surface,
    surfaceContainerLow: p.surface,
    surfaceContainerLowest: p.surface,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: PtText.family,
    colorScheme: scheme,
  );
  final tt = base.textTheme.apply(
    bodyColor: p.text,
    displayColor: p.text,
    fontFamilyFallback: PtText.debugFontFallback,
  );
  final radiusSm = BorderRadius.circular(Pt.rSm + 2);

  return base.copyWith(
    textTheme: tt,
    extensions: [p],
    scaffoldBackgroundColor: p.bg,
    canvasColor: p.bg,
    primaryColor: p.primary,
    splashFactory: InkRipple.splashFactory,
    splashColor: p.primary.withValues(alpha: 0.08),
    highlightColor: p.primary.withValues(alpha: 0.04),
    dividerColor: p.border,
    dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PtPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: PtPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: PtPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      foregroundColor: p.text,
      titleTextStyle: PtText.headline(color: p.text).copyWith(fontSize: 19),
      iconTheme: IconThemeData(color: p.text),
      systemOverlayStyle: p.isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Pt.rMd),
        side: p.isDark ? BorderSide(color: p.border) : BorderSide.none,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: p.surface,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Pt.rLg)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Pt.rLg),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Pt.rSm),
      ),
      textStyle: PtText.body(color: p.text),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.isDark ? p.surfaceAlt : p.text,
      contentTextStyle: PtText.body(color: p.isDark ? p.text : p.surface),
      elevation: 0,
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Pt.rMd),
        side: p.isDark ? BorderSide(color: p.border) : BorderSide.none,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : p.textFaint,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.primary : p.sunken,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.transparent : p.border,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.primary,
      linearTrackColor: p.sunken,
      circularTrackColor: Colors.transparent,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.primary,
      selectionColor: p.primary.withValues(alpha: 0.3),
      selectionHandleColor: p.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.sunken,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: radiusSm,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radiusSm,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radiusSm,
        borderSide: BorderSide(color: p.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radiusSm,
        borderSide: BorderSide(color: p.danger, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radiusSm,
        borderSide: BorderSide(color: p.danger, width: 2),
      ),
      labelStyle: PtText.body(color: p.textMuted),
      floatingLabelStyle: PtText.small(
        color: p.primary,
        weight: FontWeight.w600,
      ),
      hintStyle: PtText.body(color: p.textFaint),
      suffixStyle: PtText.body(color: p.textMuted),
      prefixIconColor: p.textMuted,
      suffixIconColor: p.textMuted,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(p.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: p.surface,
      dialBackgroundColor: p.sunken,
      hourMinuteColor: p.sunken,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Pt.rLg),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primary,
        minimumSize: const Size(48, 48),
        textStyle: PtText.button().copyWith(fontSize: 15),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: p.text,
        minimumSize: const Size(48, 48),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: p.isDark ? p.surfaceAlt : p.text,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: PtText.small(color: p.isDark ? p.text : p.surface),
    ),
  );
}
