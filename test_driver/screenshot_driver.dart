// Driver that writes screenshots captured by integration_test/screenshot_test.dart
// to disk under store/screenshots/raw/.
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final dir = Directory('store/screenshots/raw');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final file = File('${dir.path}/$name.png');
      await file.writeAsBytes(bytes);
      // ignore: avoid_print
      print('Saved ${file.path}');
      return true;
    },
  );
}
