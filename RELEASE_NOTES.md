# Whisky GPTK 3.2.0

Release date: 2026-03-28
Bundle version: 47

Security and publication cleanup release for the maintained Whisky GPTK fork.

## Highlights

- Hardened Terminal launch and install flows so AppleScript command strings remain escaped correctly
- Hardened generated terminal commands so user-provided arguments and environment values are shell-escaped
- Corrected DOSBox Staging config generation to current option names used by modern releases
- Updated project metadata and links for publication from the new `Einnovoeg/WhiskyGPTK` repository
- Tightened shortcut launcher permissions and expanded hover help across the main UI sheets and menus
- Kept the dual-runner model and current GPTK runtime handling intact while tightening release and compliance metadata

## Upgrade Notes

- Existing Whisky bottle data is migrated through legacy bundle identifier detection.
- Winetricks now requires an external `cabextract` install:
  - `brew install cabextract`
- DOS support requires an external DOSBox Staging install:
  - `brew install dosbox-staging`
- Public release artifacts are unsigned unless otherwise stated.

## Verification

- `swift build` for `WhiskyKit` succeeded
- DOSBox Staging 0.82.2 accepted the generated config without invalid or deprecated-option warnings
- DOSBox mounted the bottle-local `DOS Games` folder successfully during smoke testing
