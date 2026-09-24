#!/usr/bin/env bash
set -euo pipefail
sdk_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
sdk_check=$(mktemp -d)
trap 'rm -rf "$sdk_check"' EXIT
mkdir -p "$sdk_check/package/Sources"
cp "$sdk_root/Package.swift" "$sdk_root/PodcastAPI.podspec" "$sdk_root/README.md" "$sdk_root/LICENSE" "$sdk_check/package/"
cp -R "$sdk_root/Sources/PodcastAPI" "$sdk_root/Sources/ExampleCommandLineApp" "$sdk_check/package/Sources/"
cp -R "$sdk_root/Tests" "$sdk_check/package/"
cd "$sdk_check/package"
# No Git checkout, submodules, or monorepo files are available in this directory.
swift package dump-package > "$sdk_check/manifest.json"
swift test
# Compile every generated README example without executing API requests.
mkdir -p Sources/ReadmeExamples
awk '
  /<!-- BEGIN GENERATED API REFERENCE -->/ { reference = 1 }
  reference && /^```swift$/ { example++; active = 1; next }
  active && /^```$/ { active = 0; next }
  active && /^import / { next }
  active && /^@main$/ { next }
  active { gsub(/struct Example \{/, "struct Example" example " {"); print }
' README.md > Sources/ReadmeExamples/Examples.swift
sdk_examples=$(cat Sources/ReadmeExamples/Examples.swift)
printf 'import Foundation\nimport PodcastAPI\n%s\n' "$sdk_examples" > Sources/ReadmeExamples/Examples.swift
perl -0pi -e 's/targets: \[\n/targets: [\n        .target(name: "ReadmeExamples", dependencies: ["PodcastAPI"]),\n/' Package.swift
swift build --target ReadmeExamples -Xswiftc -warnings-as-errors
