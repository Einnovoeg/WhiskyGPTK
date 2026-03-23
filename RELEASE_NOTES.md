# Whisky GPTK 3.0.0

Release date: 2026-03-23
Bundle version: 45

First maintained release of the Whisky GPTK fork.

## Highlights

- Updated runtime sourcing to maintained GPTK releases from `Gcenx/game-porting-toolkit`
- Added support for mounted local Apple GPTK runtimes and `redist` overlays
- Renamed the shipped app product to `Whisky GPTK`
- Modernized the macOS UI with optional glass styling and new brand assets
- Fixed bottle registration/import issues and several archived-upstream reliability problems
- Removed bundled `cabextract` from the repository and switched Winetricks to an external dependency model
- Added changelog, dependency documentation, third-party notices, and release automation for the fork
- Added maintained repository, issue tracker, release links, and support metadata for distributed builds

## Upgrade Notes

- Existing Whisky bottle data is migrated through legacy bundle identifier detection.
- Winetricks now requires an external `cabextract` install:
  - `brew install cabextract`
- Public release artifacts are unsigned unless otherwise stated.

## Verification

- Debug build succeeded
- Release build succeeded
- `WhiskyCmd --help` succeeded
- App launch smoke test succeeded
- Runtime resolution and install flow verified against current maintained GPTK packages
