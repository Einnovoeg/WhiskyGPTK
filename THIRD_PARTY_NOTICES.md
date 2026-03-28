# Third-Party Notices

Whisky GPTK is a derivative of the archived Whisky project and remains licensed under GPL-3.0-or-later.
This repository also depends on third-party projects with their own licenses and attribution requirements.

## Original Project Credit

- Project: Whisky
- Repository: https://github.com/Whisky-App/Whisky
- License: GPL-3.0-or-later
- Credit: Original Whisky authors and contributors

## Runtime and Platform Credit

- Game Porting Toolkit runtime releases used by this fork are sourced from:
  - Gcenx/game-porting-toolkit: https://github.com/Gcenx/game-porting-toolkit
- Apple Game Porting Toolkit local installations may also be used when present on the host system.
- This repository does not ship Apple's Game Porting Toolkit installer images.
- The runtime packages consumed by this fork are Wine-derived and remain subject to Wine's upstream license terms.

### Wine

- Project: Wine
- Repository: https://gitlab.winehq.org/wine/wine
- Mirror: https://github.com/wine-mirror/wine
- License: LGPL-2.1-or-later
- Credit: Wine project authors and contributors
- Redistribution status in this repo: not bundled as source or binary
- License notice copy: `LICENSES/Wine.txt`

## Embedded or Linked Dependencies

### Sparkle

- Repository: https://github.com/sparkle-project/Sparkle
- License: Sparkle license file with MIT-style terms and bundled notices
- Copyright holders listed by upstream include:
  - Andy Matuschak
  - Elgato Systems GmbH
  - Kornel Lesiński
  - Mayur Pawashe
  - C.W. Betts
  - Petroules Corporation
  - Big Nerd Ranch
- License copy: `LICENSES/Sparkle.txt`

### SemanticVersion

- Repository: https://github.com/SwiftPackageIndex/SemanticVersion
- License: Apache-2.0
- License copy: `LICENSES/SemanticVersion.txt`

### swift-argument-parser

- Repository: https://github.com/apple/swift-argument-parser
- License: Apache-2.0
- License copy: `LICENSES/swift-argument-parser.txt`

### SwiftyTextTable

- Repository: https://github.com/scottrhoyt/SwiftyTextTable
- License: MIT
- Copyright:
  - Scott Hoyt
- License copy: `LICENSES/SwiftyTextTable.txt`

### Progress.swift

- Repository: https://github.com/jkandzi/Progress.swift
- License: MIT
- Copyright:
  - Justus Kandzi
- License copy: `LICENSES/Progress.swift.txt`

## External Tools Not Redistributed Here

### cabextract

- Homepage: https://www.cabextract.org.uk/
- Usage: optional external dependency for Winetricks support
- Redistribution status in this repo: not bundled

### DOSBox Staging

- Repository: https://github.com/dosbox-staging/dosbox-staging
- License: GPL-2.0-or-later
- Usage: optional external runtime for DOS game libraries
- Redistribution status in this repo: not bundled
- Credit: DOSBox Staging authors and contributors
- License notice copy: `LICENSES/DOSBox-Staging.txt`

## Compliance Notes

- Do not remove upstream copyright notices from original source files.
- Do not bundle third-party executables or archives without reviewing redistribution terms.
- When distributing binaries, include this notice file together with the relevant license texts in `LICENSES/`.
