import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_plate/main.dart';
import 'package:simple_plate/services/storage_service.dart';

void main() {
  testWidgets('app launches onboarding for a fresh install', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();

    await tester.pumpWidget(SimplePlateApp(storage: storage));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('app skips onboarding once it has already been completed',
      (tester) async {
    SharedPreferences.setMockInitialValues({'sp.onboarding.v1': true});
    final storage = await StorageService.init();

    await tester.pumpWidget(SimplePlateApp(storage: storage));
    await tester.pumpAndSettle();

    expect(find.text('PlateSimple'), findsWidgets);
  });
}
