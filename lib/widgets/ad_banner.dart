import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_config.dart';
import '../services/ad_service.dart';
import '../services/subscription_service.dart';

/// An anchored adaptive banner for **reading screens only**.
///
/// PlateSimple had no banner placement at all, so Today, History, Goals and
/// the food search earned nothing while the user read them — and this is an
/// app people open several times a day, once per meal. Those screens are also
/// where a banner costs least: the user is looking, not acting.
///
/// ## It must never touch the logging flow
///
/// Two rules, both enforced by construction rather than by care:
///
///  * **Placement.** Always handed to `Scaffold.bottomNavigationBar` via
///    [bar], never stacked over a body and never inside a scroll view. The
///    Scaffold lays the body out *above* it, so the body simply gets shorter:
///    no text is covered, and no tap target moves under a thumb mid-gesture.
///  * **Where.** Never the food detail screen, where an "Add to meal" button
///    sits and a misplaced tap logs the wrong thing; never the custom food or
///    recipe forms, which open a keyboard; never the barcode camera; and never
///    the Premium screen, since selling an ad-free upgrade next to an ad is
///    its own kind of argument against itself.
///
/// Collapses to a zero-height box — which a Scaffold renders as no bar at all
/// — for Premium subscribers, when Remote Config has banners off, on
/// unsupported platforms, and before the ad loads. Screens therefore lay out
/// exactly as they do today whenever no ad arrives.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  /// The banner as a `Scaffold.bottomNavigationBar`:
  ///
  /// ```dart
  /// bottomNavigationBar: AdBanner.bar(),
  /// ```
  static Widget bar() => const _AdBannerGate();

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerGate extends StatelessWidget {
  const _AdBannerGate();

  static bool get _supportedPlatform => Platform.isAndroid || Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    if (!_supportedPlatform) return const SizedBox.shrink();
    if (!AdConfig.instance.bannerEnabled) return const SizedBox.shrink();
    // Listened to, not read once: buying Premium mid-session must remove the
    // banner without needing a screen change.
    return ListenableBuilder(
      listenable: SubscriptionService.instance,
      builder: (context, _) {
        if (SubscriptionService.instance.isPremium) {
          return const SizedBox.shrink();
        }
        return const SafeArea(top: false, child: AdBanner());
      },
    );
  }
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The adaptive size is derived from screen width, which needs a
    // MediaQuery, so this cannot happen in initState.
    _maybeLoad();
  }

  Future<void> _maybeLoad() async {
    if (_requested) return;
    if (SubscriptionService.instance.isPremium) return;
    _requested = true;

    final width = MediaQuery.of(context).size.width.truncate();
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );
    if (size == null || !mounted) return;

    final ad = BannerAd(
      adUnitId: AdService.bannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _ad = null;
            _loaded = false;
          });
        },
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
