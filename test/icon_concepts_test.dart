import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/ui/kit.dart';

import 'helpers/ui_harness.dart';

/// App-icon concepts featuring Sprout, drawn with the app's own Sprout
/// widget so the icon matches the app exactly. Concepts only: nothing here
/// touches the real launcher icon.
///
/// Regenerate (repo root):
///   flutter test --dart-define=ICON_CONCEPTS=true test/icon_concepts_test.dart
///   python store_assets/icon_concepts/make_overview.py
/// Writes store_assets/icon_concepts/{A,B,C}_*.png (1024, opaque) plus the
/// Android adaptive layers *_adaptive_fg.png / *_adaptive_bg.png.
/// Without the define it only builds them (smoke test). Adapted from the
/// Word Waves icon pipeline.
const bool kWriteConcepts = bool.fromEnvironment('ICON_CONCEPTS');
const String kOut = 'store_assets/icon_concepts';

// Palette (lib/ui/theme/plate_theme.dart) and the current icon's colours.
const _linen = Color(0xFFF1ECE2);
const _linenDeep = Color(0xFFE6DCCB);
const _track = Color(0xFFE1DACB);
const _fresh = Color(0xFF36B46E);
const _protein = Color(0xFF4F9DE0);
const _carbs = Color(0xFFF3A73B);

class _Concept {
  const _Concept(this.id, this.name, this.background, this.subject);
  final String id;
  final String name;

  /// Full-bleed ground (also the adaptive background layer).
  final Widget Function() background;

  /// Everything that must stay visible, laid out in a 1000x1000 box.
  final Widget Function() subject;
}

Widget sprout(SproutMood mood, double width) => Theme(
  data: buildPlateTheme(Brightness.light),
  child: Sprout(mood: mood, size: width),
);

/// Ring segments: (colour, sweep in degrees), clockwise from 12 o'clock.
class _RingPainter extends CustomPainter {
  _RingPainter(this.segments, {this.stroke = 0.17, this.round = false});
  final List<(Color, double)> segments;
  final double stroke;
  final bool round;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final sw = s * stroke;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (s - sw) / 2,
    );
    var start = -90.0;
    for (final (c, sweep) in segments) {
      final paint = Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = round ? StrokeCap.round : StrokeCap.butt;
      canvas.drawArc(
        rect,
        start * math.pi / 180,
        sweep * math.pi / 180,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => false;
}

Widget _linenGround() => const DecoratedBox(
  decoration: BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(-0.3, -0.4),
      radius: 1.2,
      colors: [Color(0xFFF8F4EC), _linen, _linenDeep],
      stops: [0, 0.6, 1],
    ),
  ),
);

Widget _dish(double size) => Container(
  width: size,
  height: size,
  decoration: const BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 8)),
    ],
  ),
);

// ------------------------------------------------- A: Sprout on the plate
// Today's icon (linen, white plate, green/orange/blue ring) with Sprout
// sitting on the plate: the same icon people know, now with a face.
Widget _aSubject() => Stack(
  alignment: Alignment.center,
  children: [
    CustomPaint(
      size: const Size(1000, 1000),
      painter: _RingPainter([
        (_fresh, 150),
        (_carbs, 100),
        (_protein, 78),
        (_track, 32),
      ]),
    ),
    _dish(680),
    Transform.translate(
      offset: const Offset(0, -18),
      child: sprout(SproutMood.happy, 600),
    ),
  ],
);

// ------------------------------------------------- B: Sprout close-up
// A big, happy Sprout on herb green, a white plate behind: the most
// characterful option, readable as "a green pea with a face" at any size.
Widget _bBackground() => const DecoratedBox(
  decoration: BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(-0.3, -0.45),
      radius: 1.15,
      colors: [Color(0xFF5BC98A), Color(0xFF2E9E5E), Color(0xFF1C7442)],
      stops: [0, 0.55, 1],
    ),
  ),
);

Widget _bSubject() => Stack(
  alignment: Alignment.center,
  children: [
    Transform.translate(offset: const Offset(0, 90), child: _dish(900)),
    Transform.translate(
      offset: const Offset(0, 90),
      child: Container(
        width: 780,
        height: 780,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFEFE8DB), width: 10),
        ),
      ),
    ),
    Transform.translate(
      offset: const Offset(0, -10),
      child: sprout(SproutMood.celebrate, 760),
    ),
  ],
);

// ------------------------------------------------- C: Today ring
// The app's hero: the plate ring as a bold green progress arc on a linen
// track, Sprout perched on it top-right exactly as on the Today screen.
Widget _cSubject() => Stack(
  alignment: Alignment.center,
  children: [
    Transform.translate(
      offset: const Offset(-40, 40),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(860, 860),
            painter: _RingPainter([(_track, 360)], stroke: 0.17),
          ),
          CustomPaint(
            size: const Size(860, 860),
            painter: _RingPainter(
              [(_fresh, 285), (const Color(0x00000000), 75)],
              stroke: 0.17,
              round: true,
            ),
          ),
          _dish(520),
          // The plate's inner rim, as on today's icon.
          Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEDE5D6), width: 16),
            ),
          ),
        ],
      ),
    ),
    Transform.translate(
      offset: const Offset(250, -270),
      child: sprout(SproutMood.happy, 400),
    ),
  ],
);

final _concepts = [
  _Concept('A', 'sprout_on_plate', _linenGround, _aSubject),
  _Concept('B', 'sprout_closeup', _bBackground, _bSubject),
  _Concept('C', 'today_ring', _linenGround, _cSubject),
];

// ---------------------------------------------------------------- render
enum _Layer { full, fg, bg }

Widget _compose(_Concept c, _Layer layer) {
  // Full icon: subject in the central 80% (outer 10% stays clear for
  // masks). Adaptive foreground: the launcher shows the centre 72/108 and
  // the guaranteed-visible zone is a 66dp circle (~61% of the layer), so
  // the subject box is 58%: a round subject stays inside that circle.
  final subjectFraction = layer == _Layer.full ? 0.80 : 0.58;
  final box = 1024 * subjectFraction;
  return SizedBox(
    width: 1024,
    height: 1024,
    child: Stack(
      children: [
        if (layer != _Layer.fg) Positioned.fill(child: c.background()),
        if (layer != _Layer.bg)
          Positioned(
            left: (1024 - box) / 2,
            top: (1024 - box) / 2,
            width: box,
            height: box,
            child: FittedBox(
              child: SizedBox(width: 1000, height: 1000, child: c.subject()),
            ),
          ),
      ],
    ),
  );
}

void main() {
  setUpAll(() async {
    await loadUiFonts();
  });

  for (final concept in _concepts) {
    for (final layer in _Layer.values) {
      final suffix = switch (layer) {
        _Layer.full => '',
        _Layer.fg => '_adaptive_fg',
        _Layer.bg => '_adaptive_bg',
      };
      final file = '${concept.id}_${concept.name}$suffix.png';
      testWidgets('icon $file', (tester) async {
        tester.view.physicalSize = const Size(1024, 1024);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final key = GlobalKey();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: RepaintBoundary(key: key, child: _compose(concept, layer)),
            ),
          ),
        );
        await settle(tester);
        if (!kWriteConcepts) return;
        final boundary =
            tester.renderObject(find.byKey(key)) as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final out = File('$kOut/$file');
          await out.parent.create(recursive: true);
          await out.writeAsBytes(data!.buffer.asUint8List());
        });
      });
    }
  }
}
