# Whisky GPTK 3.4.0

Release date: 2026-03-29
Bundle version: 50

Compatibility preset release for the maintained Whisky GPTK fork.

## Highlights

- Added curated compatibility presets for Windows games, game launchers, Windows utilities, blank Wine bottles, blank DOS libraries, and classic DOS games
- Reworked the bottle creation sheet so preset selection and core library details are primary while advanced overrides stay hidden until needed
- Added preset reapply support in the bottle `Config` tab so existing libraries can be retuned without manual multi-toggle edits
- Added preset visibility in bottle details and CLI listings plus `WhiskyCmd create --preset ...` support
- Kept the current runner-management work from `3.3.0` intact while making the actual library setup workflow more coherent

## Upgrade Notes

- Existing Whisky bottle data is migrated through legacy bundle identifier detection.
- Existing bottles remain intact; presets are opt-in and can be applied later from the `Config` tab.
- Winetricks now requires an external `cabextract` install:
  - `brew install cabextract`
- DOS support still requires DOSBox Staging, but the app can now install or update it through Homebrew:
  - `brew install dosbox-staging`
- Native Wine 11 support is available through Homebrew if you want to switch away from the managed GPTK runtime:
  - `brew install --cask wine-stable`
- Public release artifacts are unsigned unless otherwise stated.

## Verification

- `swiftlint --strict` passed across all `272` Swift file paths in the Xcode build graph
- `swift build --package-path WhiskyKit` succeeded
- `xcodebuild` Debug build for the `Whisky` scheme succeeded
- `xcodebuild` Release build for the `Whisky` scheme succeeded
- The live app relaunched successfully and the Add action attached a modal sheet in the running window
- `WhiskyCmd --help` succeeded from both the Debug and Release app bundles
- `WhiskyCmd help create` exposed the new `--preset` option from the Release app bundle
- `WhiskyCmd create --preset classicDOSGame` succeeded in smoke testing with disposable bottles from the Debug and Release app bundles
