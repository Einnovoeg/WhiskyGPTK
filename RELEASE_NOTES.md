# Whisky GPTK 3.3.0

Release date: 2026-03-29
Bundle version: 49

Runner management release for the maintained Whisky GPTK fork.

## Highlights

- Added a `System Scan` panel in Settings so the app can inspect Rosetta, Wine runtime, DOSBox, Homebrew availability, and the recommended stability defaults for this Mac
- Added selectable Wine runtime channels for the managed GPTK runtime plus Homebrew `Wine 11 Stable`, `Wine Devel`, and `Wine Staging`
- Added one-click DOSBox Staging install/update support through Homebrew
- Kept the repaired tabbed Settings layout from `3.2.1` while turning the `Runners` tab into a focused management surface
- Updated library creation and sidebar summaries so they reflect the active runtime channel instead of assuming GPTK-only state

## Upgrade Notes

- Existing Whisky bottle data is migrated through legacy bundle identifier detection.
- Winetricks now requires an external `cabextract` install:
  - `brew install cabextract`
- DOS support still requires DOSBox Staging, but the app can now install or update it through Homebrew:
  - `brew install dosbox-staging`
- Native Wine 11 support is available through Homebrew if you want to switch away from the managed GPTK runtime:
  - `brew install --cask wine-stable`
- Public release artifacts are unsigned unless otherwise stated.

## Verification

- `swiftlint --strict` passed across all `268` Swift files
- `xcodebuild` Debug build for the `Whisky` scheme succeeded
- The repaired app window was relaunched and inspected from the built app bundle
- The new `Runners` settings tab was opened live and verified to render the new scan/install controls
- `swift build` for `WhiskyKit` succeeded
- `WhiskyCmd --help` succeeded from the built app bundle
