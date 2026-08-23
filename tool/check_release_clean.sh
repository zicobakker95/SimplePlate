#!/usr/bin/env bash
# Proves a release artifact carries none of the debug tooling in lib/debug/.
#
# The guard is `if (!kDebugMode) return null;` in debugToolsTile(). kDebugMode
# is a compile-time constant, so the AOT compiler should drop DebugMenuScreen,
# the Notification Lab and every string they own. "Should" is not evidence,
# which is what this script is for.
#
#   tool/check_release_clean.sh build/app/outputs/bundle/release/app-release.aab
#
# Exits non-zero if any debug-only string survives into the bundle.
set -uo pipefail

AAB="${1:-build/app/outputs/bundle/release/app-release.aab}"
if [ ! -f "$AAB" ]; then
  echo "no such bundle: $AAB" >&2
  echo "build one first: flutter build appbundle --release --no-tree-shake-icons" >&2
  exit 2
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
unzip -q "$AAB" -d "$WORK" || { echo "could not unzip $AAB" >&2; exit 2; }

# Dart stores strings in the AOT snapshot in one of three encodings depending
# on their contents, so a single grep is not enough — search all three.
python - "$WORK" <<'PY'
import io, os, sys, glob

work = sys.argv[1]

# The marker, plus user-visible strings that exist only in the debug screens.
NEEDLES = [
    'PLATESIMPLE_DEBUG_TOOLS_2f6d90b8',
    'Debug Tools',
    'Log a full day',
    'Fill water to the goal',
    'Set streak to 30 days',
    'Force a test crash',
    'Premium active',
    'Debug builds only',
]

# A control string that MUST be present, so a silent failure to read the
# snapshot cannot masquerade as a clean result.
CONTROL = 'PlateSimple'

snapshots = glob.glob(os.path.join(work, 'base', 'lib', '*', 'libapp.so'))
if not snapshots:
    print('FAIL: no libapp.so inside the bundle — nothing was checked')
    sys.exit(2)

def count(blob, s):
    n = 0
    for enc in ('latin-1', 'utf-8', 'utf-16-le'):
        try:
            n += blob.count(s.encode(enc))
        except UnicodeEncodeError:
            pass
    return n

bad = []
control_seen = 0
for so in snapshots:
    blob = io.open(so, 'rb').read()
    arch = os.path.basename(os.path.dirname(so))
    control_seen += count(blob, CONTROL)
    for needle in NEEDLES:
        hits = count(blob, needle)
        if hits:
            bad.append((arch, needle, hits))

if control_seen == 0:
    print('FAIL: control string %r not found in any snapshot.' % CONTROL)
    print('      The search is not reading the binary, so a "clean" result')
    print('      here would be meaningless. Fix the check, not the build.')
    sys.exit(2)

print('checked %d snapshot(s); control string found %d time(s)'
      % (len(snapshots), control_seen))

if bad:
    print()
    print('FAIL: debug tooling is present in the release bundle:')
    for arch, needle, hits in bad:
        print('  %-12s %-32s x%d' % (arch, needle, hits))
    sys.exit(1)

print('PASS: none of the %d debug-only strings appear in the release bundle.'
      % len(NEEDLES))
PY
