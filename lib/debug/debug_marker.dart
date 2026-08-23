/// A string that must never appear in a release binary.
///
/// Everything under lib/debug/ is reachable only through [debugToolsTile],
/// which returns null on a `!kDebugMode` branch. Because `kDebugMode` is a
/// compile-time constant, the AOT compiler treats the rest of that function
/// as dead and drops this subtree along with its strings.
///
/// tool/check_release_clean.sh greps a built AAB for this constant. If it is
/// ever found, the guard has stopped working and debug tooling is shipping to
/// users — which is the whole thing we are trying to prevent.
const String kDebugOnlyMarker = 'PLATESIMPLE_DEBUG_TOOLS_2f6d90b8';
