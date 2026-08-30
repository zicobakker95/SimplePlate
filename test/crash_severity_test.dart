import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_plate/utils/crash_severity.dart';

void main() {
  group('recoverable — must never be reported fatal', () {
    test('the Remote Config error that cost Deadlight 10 points', () {
      final e = PlatformException(
        code: 'firebase_remote_config/remote-config-server-error',
        message: 'Fetch failed: The server is unavailable. Please try again '
            'later.',
      );
      expect(isRecoverableError(e), isTrue);
    });

    test('an Open Food Facts lookup on an offline device', () {
      expect(isRecoverableError(const SocketException('no route')), isTrue);
      expect(isRecoverableError(TimeoutException('slow')), isTrue);
      expect(
        isRecoverableError(
            Exception("Failed host lookup: 'world.openfoodfacts.org'")),
        isTrue,
      );
    });
  });

  group('NOT recoverable — the default must stay "tell me"', () {
    test('ordinary programming errors', () {
      expect(isRecoverableError(ArgumentError('bad serving size')), isFalse);
      expect(isRecoverableError(StateError('no entries')), isFalse);
      expect(isRecoverableError(RangeError.index(3, <int>[])), isFalse);
    });

    test('an unrelated PlatformException stays fatal', () {
      expect(
        isRecoverableError(PlatformException(code: 'billing/failed')),
        isFalse,
      );
    });

    test('a corrupt stored log stays fatal — that is data loss', () {
      expect(isRecoverableError(FormatException('bad entry json')), isFalse);
    });
  });
}
