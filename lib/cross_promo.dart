import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

/// The two ZiBa app families used for in-app cross-promotion.
enum ZibaGroup { games, wellness }

/// One ZiBa app in the cross-promotion registry.
class ZibaApp {
  final String id; // internal key, used to exclude the current app
  final String name;
  final String tagline;
  final String appleId; // App Store numeric id; empty = not on the App Store
  final String androidId; // Play Store package name
  final IconData icon;
  final Color color;
  final ZibaGroup group;
  const ZibaApp(this.id, this.name, this.tagline, this.appleId, this.androidId,
      this.icon, this.color, this.group);

  /// The App Store on iOS, Play everywhere else. An app with no App Store
  /// listing is never shown on iOS ([zibaAppsFor]), so the Play fallback
  /// only ever serves Android.
  String get storeUrl =>
      defaultTargetPlatform == TargetPlatform.iOS && appleId.isNotEmpty
          ? 'https://apps.apple.com/app/id$appleId'
          : 'https://play.google.com/store/apps/details?id=$androidId';

  /// Bundled App Store icon, shipped in every app under assets/promo/.
  String get iconAsset => 'assets/promo/$id.png';
}

/// PlateSimple's App Store id, for the settings "Rate PlateSimple" row.
const kSelfAppleId = '6781796015';

/// Where the settings feedback row goes.
final kFeedbackUri =
    Uri.parse('https://zibaentertainment.com/feedback/?app=platesimple');

/// The full ZiBa catalogue. Keep in sync across apps.
const List<ZibaApp> kZibaApps = [
  // Games
  ZibaApp('deadlight', 'Deadlight', 'Zombie survival', '6780618209',
      'com.deadlight.zibaentertainment', Icons.dark_mode_rounded,
      Color(0xFFB83232), ZibaGroup.games),
  ZibaApp('lafamiglia', 'La Famiglia', 'Mafia family saga', '',
      'com.zibagames.la_famiglia_mobile', Icons.local_bar_rounded,
      Color(0xFF8E1F1F), ZibaGroup.games),
  ZibaApp('klacksort', 'Klack Sort', 'Color-sort puzzle', '6786612509',
      'com.zibagames.klack_sort', Icons.view_week_rounded, Color(0xFF8B6BEA),
      ZibaGroup.games),
  ZibaApp('klack', 'Klack', 'Neon bounce arcade', '6785994807',
      'com.klack.klack', Icons.blur_on_rounded, Color(0xFFF5C518),
      ZibaGroup.games),
  // Wellness / self-help
  ZibaApp('streaks', 'Streaks', 'Habit & goal tracker', '6780628137',
      'com.streaks.zibaentertainment', Icons.local_fire_department_rounded,
      Color(0xFFFF8A34), ZibaGroup.wellness),
  ZibaApp('platesimple', 'PlateSimple', 'Calorie counter', '6781796015',
      'com.zibaentertainment.simple_plate', Icons.restaurant_rounded,
      Color(0xFF2E9B53), ZibaGroup.wellness),
  ZibaApp('medmate', 'MedMate', 'Pill reminder', '6781812196',
      'com.zibaentertainment.medmate', Icons.medication_rounded,
      Color(0xFF2563EB), ZibaGroup.wellness),
  ZibaApp('wordwaves', 'Word Waves', 'Learn languages', '6743080817',
      'com.wordwave.app', Icons.translate_rounded, Color(0xFF3AA0FF),
      ZibaGroup.wellness),
];

/// The apps to list: everything but [selfId], in [group] when one is given,
/// and on iOS only those with an App Store listing (an iPhone user is never
/// sent to Google Play).
List<ZibaApp> zibaAppsFor(
    {required String selfId, ZibaGroup? group, TargetPlatform? platform}) {
  final ios = (platform ?? defaultTargetPlatform) == TargetPlatform.iOS;
  return [
    for (final a in kZibaApps)
      if (a.id != selfId &&
          (group == null || a.group == group) &&
          (!ios || a.appleId.isNotEmpty))
        a,
  ];
}

/// Opens PlateSimple's store page (App Store on iOS, Play on Android) so the
/// user can leave a review. Never throws.
Future<void> openSelfStoreListing({InAppReview? review}) async {
  try {
    await (review ?? InAppReview.instance)
        .openStoreListing(appStoreId: kSelfAppleId);
  } catch (e) {
    debugPrint('[rate] could not open the store listing: $e');
  }
}

/// Opens [uri] in the browser or the store app. Never throws.
Future<bool> openZibaLink(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('[ziba] could not open $uri: $e');
    return false;
  }
}

/// A settings section that cross-promotes the other ZiBa apps in the same
/// [group], excluding [selfId]. Colours are passed so it matches each app.
class MoreFromZiba extends StatelessWidget {
  const MoreFromZiba({
    super.key,
    required this.selfId,
    this.group,
    required this.title,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.borderColor,
  });

  final String selfId;

  /// Which family to show; null lists every ZiBa app.
  final ZibaGroup? group;
  final String title;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final apps = zibaAppsFor(selfId: selfId, group: group);
    if (apps.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
          child: Text(title.toUpperCase(),
              style: TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5)),
        ),
        for (final a in apps) _row(a),
      ],
    );
  }

  Widget _row(ZibaApp a) => Padding(
        key: Key('ziba_app_${a.id}'),
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => openZibaLink(Uri.parse(a.storeUrl)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.asset(
                      a.iconAsset,
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                      // Fall back to the tinted glyph if the asset is missing.
                      errorBuilder: (_, _, _) => Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: a.color.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(a.icon, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.name,
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(a.tagline,
                            style: TextStyle(color: mutedColor, fontSize: 12.5)),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new_rounded, color: mutedColor, size: 18),
                ],
              ),
            ),
          ),
        ),
      );
}
