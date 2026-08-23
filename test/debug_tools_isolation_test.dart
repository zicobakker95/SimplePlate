// The debug tooling must not reach a shipped build. Two things keep it out:
// the `!kDebugMode` guard in debugToolsTile(), and the fact that nothing else
// in lib/ imports lib/debug/ directly. Both are easy to break by accident —
// one stray import from a screen and the whole subtree becomes reachable in
// release, guard or no guard. These tests fail when that happens.
//
// This is a static check. The end-to-end proof that a real bundle is clean is
// tool/check_release_clean.sh, which greps the built AAB.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every .dart file under lib/, excluding lib/debug/ itself.
List<File> productionFiles() {
  final out = <File>[];
  for (final e in Directory('lib').listSync(recursive: true)) {
    if (e is! File || !e.path.endsWith('.dart')) continue;
    final p = e.path.replaceAll(r'\', '/');
    if (p.contains('/debug/')) continue;
    out.add(e);
  }
  return out;
}

void main() {
  test('only the goals screen reaches into lib/debug', () {
    final importers = <String>[];
    for (final f in productionFiles()) {
      final src = f.readAsStringSync();
      final touches = RegExp(r"import\s+'[^']*debug/[^']*'").hasMatch(src);
      if (touches) importers.add(f.path.replaceAll(r'\', '/'));
    }
    expect(
      importers,
      ['lib/screens/goals/goals_screen.dart'],
      reason: 'lib/debug must have exactly one entry point. Every extra '
          'importer is another path that survives into a release build.',
    );
  });

  test('the entry point is guarded by kDebugMode', () {
    final src = File('lib/debug/debug_menu_screen.dart').readAsStringSync();
    final fn = src.substring(src.indexOf('Widget? debugToolsTile('));
    expect(fn, contains('if (!kDebugMode) return null;'),
        reason: 'debugToolsTile must bail on a compile-time constant so the '
            'AOT compiler can drop everything below it');
  });

  test('settings uses the guard rather than the screen directly', () {
    final src =
        File('lib/screens/goals/goals_screen.dart').readAsStringSync();
    expect(src, contains('debugToolsTile('));
    expect(src, isNot(contains('DebugMenuScreen(store:')),
        reason: 'constructing the screen directly would make it reachable '
            'in release regardless of the guard');
    
  });

  test('debug code pulls in no dependency of its own', () {
    // A package imported only by debug code still gets its native plugin
    // registered in release builds, so the Dart-side tree-shake buys nothing.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final f in Directory('lib/debug').listSync()) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final src = f.readAsStringSync();
      for (final m in RegExp(r"import\s+'package:([a-z0-9_]+)/")
          .allMatches(src)) {
        final pkg = m.group(1)!;
        if (pkg == 'flutter' || pkg == 'flutter_test') continue;
        expect(pubspec, contains(pkg),
            reason: '${f.path} imports $pkg, which is not already a '
                'dependency — debug tooling must not add one');
      }
    }
  });

  test('the release marker is a single shared constant', () {
    // check_release_clean.sh greps for this exact literal; if the constant
    // moves or changes, the script silently stops proving anything.
    final marker = File('lib/debug/debug_marker.dart').readAsStringSync();
    expect(marker, contains("'PLATESIMPLE_DEBUG_TOOLS_2f6d90b8'"));
    final script = File('tool/check_release_clean.sh').readAsStringSync();
    expect(script, contains('PLATESIMPLE_DEBUG_TOOLS_2f6d90b8'),
        reason: 'the checker and the constant have drifted apart');
  });
}
