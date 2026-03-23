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

## Optional External Tools

- `cabextract`
  - Required for Winetricks verbs in public builds
  - Install with `brew install cabextract`

## Notes

- This repository does not vendor full Game Porting Toolkit archives.
- Runtime payloads are installed at first run or setup time.
- Third-party license information is documented in `THIRD_PARTY_NOTICES.md` and `LICENSES/`.
