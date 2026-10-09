import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/screens/home/home_shell.dart';

int _inits = 0;

class _Page extends StatefulWidget {
  const _Page();
  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  @override
  void initState() {
    super.initState();
    _inits++;
  }

  @override
  Widget build(BuildContext context) => const Text('page');
}

Widget _host(bool visible) => MaterialApp(
      home: Scaffold(body: TabFadeIn(visible: visible, child: const _Page())),
    );

void main() {
  testWidgets('switching to a tab fades it in without rebuilding it from scratch',
      (t) async {
    _inits = 0;
    await t.pumpWidget(_host(true));
    expect(_inits, 1);
    await t.pumpWidget(_host(false)); // switched away
    await t.pumpWidget(_host(true)); // and back: the fade runs
    for (var i = 0; i < 30; i++) {
      await t.pump(const Duration(milliseconds: 16));
    }
    await t.pumpAndSettle();
    expect(_inits, 1, reason: 'the tab keeps its state through the fade');
    expect(find.text('page'), findsOneWidget);
  });
}
