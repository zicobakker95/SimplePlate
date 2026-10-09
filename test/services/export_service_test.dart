import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/services/export_service.dart';

void main() {
  testWidgets('the share origin is the tapped widget\'s rect (iPad popover)',
      (tester) async {
    late BuildContext tileContext;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 40),
            child: Builder(builder: (context) {
              tileContext = context;
              return const SizedBox(width: 200, height: 56);
            }),
          ),
        ),
      ),
    );

    expect(ExportService.shareOriginOf(tileContext),
        const Rect.fromLTWH(20, 40, 200, 56));
  });

  testWidgets('a widget without a size gives no origin', (tester) async {
    late BuildContext tileContext;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Builder(builder: (context) {
            tileContext = context;
            return const SizedBox.shrink();
          }),
        ),
      ),
    );

    expect(ExportService.shareOriginOf(tileContext), isNull);
  });
}
