# Whisky GPTK

Whisky GPTK is a maintained macOS fork of the archived [Whisky](https://github.com/Whisky-App/Whisky) project.
It provides a native SwiftUI interface for running Windows games and apps on Apple Silicon Macs with Wine and Game Porting Toolkit runtimes, and now also supports classic DOS titles through DOSBox Staging.

Current maintained release:

- Version: `3.2.0`
- Release date: `2026-03-28`
- App bundle: `Whisky GPTK`
- Product: `WhiskyGPTK.app`

## Project Status

- Upstream `Whisky-App/Whisky` is archived and no longer maintained.
- This fork keeps the application working with current GPTK runtime sources.
- The app can install the latest maintained runtime from [Gcenx/game-porting-toolkit](https://github.com/Gcenx/game-porting-toolkit) or use a locally mounted Apple Game Porting Toolkit installation.
- The app can also manage DOS game libraries with a native DOSBox Staging runner.

## What It Does

- Creates and manages GPTK Wine bottles for Windows games and apps.
- Creates DOSBox libraries for classic DOS games.
- Installs and updates a maintained GPTK-based runtime.
- Detects local Game Porting Toolkit volumes and optional Apple `redist` overlays.
- Detects DOSBox Staging installations, supports a manual DOSBox binary override, and generates per-library DOSBox config files.
- Exposes common bottle actions such as opening `C:` drive or DOS games folders, terminal access, Winetricks, and shader cache cleanup.
- Includes a refreshed macOS-style interface with optional glass effects.
- Includes `WhiskyCmd` for basic command-line bottle management.

## Requirements

- Apple Silicon Mac
- macOS 14.0 or later
- Xcode 26.3 or later to build from source
- Swift Package Manager access for package dependencies
- Homebrew `cabextract` if you want Winetricks support in public builds
- DOSBox Staging if you want native DOS game support

## Install

### Option 1: Build From Source

1. Clone the repository.
2. Open `Whisky.xcodeproj` in Xcode.
3. Install SwiftLint if you want local lint parity with CI:
   - `brew install swiftlint`
4. Build the `Whisky` scheme.
5. Launch `WhiskyGPTK.app` from Xcode or the generated build products.
6. Install DOSBox Staging if you want DOS libraries:
   - `brew install dosbox-staging`

### Option 2: GitHub Release

If a release asset is attached to the release page, download the published archive for that version.
Unsigned builds may require manual approval in Gatekeeper, or you can build from source yourself.

## Runtime Model

Whisky GPTK does not vendor large Game Porting Toolkit runtime archives in this repository.
Instead, the app resolves runtimes in this order:

1. Latest maintained release from `Gcenx/game-porting-toolkit`
2. A newer locally mounted Apple Game Porting Toolkit runtime, if present
3. Legacy upstream runtime metadata only as a fallback path

Winetricks support requires `cabextract` to be installed separately:

```bash
brew install cabextract
```

DOSBox support requires DOSBox Staging to be installed separately:

```bash
brew install dosbox-staging
```

## Runner Model

Whisky GPTK now supports two runner types:

1. `GPTK Wine`
   - For Windows games and apps
   - Uses Game Porting Toolkit, D3DMetal, optional DXVK, and Wine bottle configuration
2. `DOSBox`
   - For DOS-era games and installers
   - Mounts each library's `DOS Games` folder as drive `C:`
   - Stores a generated `dosbox-staging.conf` alongside the library metadata

This is deliberately similar to the runner model popularized by tools like Lutris, but scoped to a native macOS app and the runtimes that make sense here.

## Wine 11.0 Notes

Wine 11.0 brought major upstream work in two areas that matter to this fork:

1. `NTSYNC`
   - Important upstream, but Linux-only
   - Not exposed here because macOS GPTK builds cannot use the Linux kernel driver it depends on
2. `WoW64`
   - Important for future GPTK adoption
   - This fork is structured so newer upstream Wine/GPTK runtime changes can be adopted without conflating Windows and DOS library management

For DOS-era games, DOSBox Staging is still the correct compatibility path.

## Upstream Reference Points

- [Lutris](https://lutris.net/about) helped validate the runner-model direction: one launcher surface, multiple execution backends.
- [Wine 11.0](https://www.winehq.org/news/2026011301) confirmed that the relevant upstream themes are WoW64 progress and correctly excluding Linux-only NTSYNC from the macOS runner path.

## Development

- Main build target: `Whisky`
- App product name: `WhiskyGPTK.app`
- CLI helper: `WhiskyCmd`
- Package manifest: `WhiskyKit/Package.swift`
- Dependency reference: [DEPENDENCIES.md](DEPENDENCIES.md)
- Changelog: [CHANGELOG.md](CHANGELOG.md)
- Third-party notices: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)

## Project Resources

- Installation guide: this `README.md`
- Changelog: [CHANGELOG.md](CHANGELOG.md)
- Dependencies: [DEPENDENCIES.md](DEPENDENCIES.md)
- Project notice: [NOTICE.md](NOTICE.md)
- Third-party notices: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)
- Release notes: [RELEASE_NOTES.md](RELEASE_NOTES.md)
- License texts: [LICENSE](LICENSE) and [LICENSES/](LICENSES/)
- Releases: [GitHub Releases](https://github.com/Einnovoeg/WhiskyGPTK/releases)
- Issues: [Issue Tracker](https://github.com/Einnovoeg/WhiskyGPTK/issues)

Use the issue tracker and release page provided by the repository host for the specific copy of the project you are using.

## Support

- Buy Me a Coffee: [buymeacoffee.com/einnovoeg](https://buymeacoffee.com/einnovoeg)

## Credits

Whisky GPTK remains a derivative work of the original Whisky project and preserves that project's GPL licensing.
Additional credit and license notices for bundled or linked dependencies are listed in [NOTICE.md](NOTICE.md) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

Key upstream projects include:

- [Whisky](https://github.com/Whisky-App/Whisky)
- [Gcenx/game-porting-toolkit](https://github.com/Gcenx/game-porting-toolkit)
- [Sparkle](https://github.com/sparkle-project/Sparkle)
- [swift-argument-parser](https://github.com/apple/swift-argument-parser)
- [SemanticVersion](https://github.com/SwiftPackageIndex/SemanticVersion)
- [SwiftyTextTable](https://github.com/scottrhoyt/SwiftyTextTable)
- [Progress.swift](https://github.com/jkandzi/Progress.swift)

## License

This project is licensed under the GNU General Public License, version 3 or later. See [LICENSE](LICENSE).
