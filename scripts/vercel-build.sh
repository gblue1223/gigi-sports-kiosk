#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
# Dart compilation declarations are separate from shell environment variables.
# Validate before downloading an SDK or starting a costly build.
cms_base_url="$(node scripts/cms-build-config.mjs)"

if [[ -n "${FLUTTER_BIN:-}" ]]; then
  flutter_bin="$FLUTTER_BIN"
elif command -v flutter >/dev/null 2>&1; then
  flutter_bin="$(command -v flutter)"
else
  sdk_dir="$PWD/.flutter-sdk"
  # Match the version used to analyze, test and build this project locally.
  flutter_revision="ff37bef603469fb030f2b72995ab929ccfc227f0"
  if [[ ! -d "$sdk_dir" ]]; then
    git clone --depth 1 --branch 3.41.4 https://github.com/flutter/flutter.git "$sdk_dir"
  fi
  if [[ "$(git -C "$sdk_dir" rev-parse HEAD)" != "$flutter_revision" ]]; then
    printf '%s\n' 'Unexpected Flutter SDK revision in .flutter-sdk; use a clean build environment.' >&2
    exit 1
  fi
  flutter_bin="$sdk_dir/bin/flutter"
fi

export CI=true
"$flutter_bin" config --no-analytics
"$flutter_bin" pub get
"$flutter_bin" build web --release "--dart-define=CMS_BASE_URL=$cms_base_url"
