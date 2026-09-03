#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

DEVICE="${1:-emulator-5554}"
LAN_IP="$(ipconfig getifaddr en0 2>/dev/null || true)"

echo "Stopping stale Gradle daemons..."
./android/gradlew --stop 2>/dev/null || true
rm -f ~/.gradle/daemon/8.14/registry.bin ~/.gradle/daemon/8.14/registry.bin.lock 2>/dev/null || true

if ! nc -z 127.0.0.1 1 2>/dev/null; then
  echo ""
  echo "WARNING: localhost TCP is broken on this Mac (Gradle needs it)."
  echo "Try these fixes, then run this script again:"
  echo "  1. Turn off VPN and Personal Hotspot"
  echo "  2. sudo ifconfig lo0 down && sudo ifconfig lo0 up"
  echo "  3. Reboot your Mac"
  echo ""
  if [[ -n "$LAN_IP" ]]; then
    echo "Attempting Gradle workaround with LAN IP: $LAN_IP"
    export OPENSHIFT_BUILD_IP="$LAN_IP"
  fi
fi

flutter run -d "$DEVICE"
