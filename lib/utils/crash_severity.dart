import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart'
    show PlatformException, MissingPluginException;

/// Whether [error] is something the app recovers from on its own, and so must
/// not be reported to Crashlytics as a fatal crash.
///
/// Ported from Deadlight after a measured regression there. Its `AdConfig.init`
/// ends with a deliberately un-awaited `fetchAndActivate()`; when Google's
/// Remote Config backend was briefly unavailable that future rejected, nothing
/// caught it, and it reached `PlatformDispatcher.onError`, which recorded it
/// `fatal: true`. In one week that single transient network error accounted for
/// 471 of 476 crashes across 273 users and took crash-free users to 89.9%.
///
/// No user ever saw a crash — an unhandled async error does not kill a Flutter
/// app. What it cost was visibility: every real crash was buried underneath.
///
/// PlateSimple has the same un-awaited fetch and, until this landed, an
/// unconditional `fatal: true`. Recoverable errors are still reported, just as
/// non-fatal. Anything not listed here stays fatal: the default must be "tell
/// me", not "hide it".
bool isRecoverableError(Object error) {
  if (error is SocketException) return true;
  if (error is TimeoutException) return true;
  if (error is HttpException) return true;
  // A plugin missing on a given device degrades one feature; it never stops
  // the app running.
  if (error is MissingPluginException) return true;

  final text = error.toString();

  // Remote Config: transient backend and throttling failures. The previous
  // fetch is already active and every getter has a shipped default, so a
  // failed refresh changes nothing the user can see.
  if (error is PlatformException && text.contains('firebase_remote_config')) {
    return true;
  }
  if (text.contains('remote-config-server-error') ||
      text.contains('remote-config-fetch-throttled') ||
      text.contains('remote-config-internal-error')) {
    return true;
  }

  // Open Food Facts lookups fail whenever the device is offline or the API is
  // slow. The search screen already surfaces this to the user.
  return text.contains('Failed host lookup') ||
      text.contains('SocketException') ||
      text.contains('Connection closed') ||
      text.contains('Connection reset');
}
