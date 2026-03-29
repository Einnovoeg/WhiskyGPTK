# Dependencies

## Build Dependencies

- Xcode 26.3 or later
- Swift 6 toolchain shipped with Xcode
- Swift Package Manager
- SwiftLint for local lint parity and CI consistency

## Swift Package Dependencies

- Sparkle
  - Source: `https://github.com/sparkle-project/Sparkle`
  - Pin: branch `2.x` at revision `8de8db001ea3c781f5e2b1c9abe851209dd8c08a`
- SemanticVersion
  - Source: `https://github.com/SwiftPackageIndex/SemanticVersion`
  - Pin: `0.4.0`
- swift-argument-parser
  - Source: `https://github.com/apple/swift-argument-parser.git`
  - Pin: `1.5.0`
- SwiftyTextTable
  - Source: `https://github.com/scottrhoyt/SwiftyTextTable`
  - Pin: `0.9.0`
- Progress.swift
  - Source: `https://github.com/jkandzi/Progress.swift`
  - Pin: `0.4.0`

## Runtime Dependencies

- Apple Silicon Mac
- macOS 14.0 or later
- Rosetta 2 for x86 Windows game support paths
- Game Porting Toolkit runtime
  - Automatically resolved from `Gcenx/game-porting-toolkit`, or
  - Detected from a locally mounted Apple Game Porting Toolkit installation
- Wine-compatible helper tools expected by the selected GPTK runtime release

## Optional External Tools

- Homebrew
  - Optional, but required for one-click Wine 11 and DOSBox installs from inside the app
  - Install from `https://brew.sh`
- `cabextract`
  - Required for Winetricks verbs in public builds
  - Install with `brew install cabextract`
- DOSBox Staging
  - Optional runner for DOS-era games and installers
  - Install with `brew install dosbox-staging`
  - Redistribution status in this repo: not bundled
- WineHQ macOS builds via Homebrew casks
  - Optional native Wine alternatives to the managed GPTK runtime
  - Stable: `brew install --cask wine-stable`
  - Devel: `brew install --cask wine@devel`
  - Staging: `brew install --cask wine@staging`
  - Redistribution status in this repo: not bundled

## Notes

- This repository does not vendor full Game Porting Toolkit archives.
- This repository does not vendor DOSBox Staging binaries.
- This repository does not vendor Homebrew Wine binaries.
- Runtime payloads are installed at first run or setup time.
- Third-party license information is documented in `THIRD_PARTY_NOTICES.md` and `LICENSES/`.
