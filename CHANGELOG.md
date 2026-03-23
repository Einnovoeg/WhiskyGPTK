# Changelog

All notable changes to this project will be documented in this file.

The format is loosely based on Keep a Changelog and versioned with Semantic Versioning.

## [3.0.0] - 2026-03-23

### Added

- Added maintained runtime resolution through `Gcenx/game-porting-toolkit`.
- Added support for locally mounted Apple Game Porting Toolkit runtimes and `redist` overlays.
- Added runtime controls in Settings, including update checks, auto-install, and local-runtime preference.
- Added a refreshed macOS-oriented interface with optional glass styling and new brand assets.
- Added support links, funding link, dependency documentation, notices, and release metadata for the fork.
- Added a maintained release workflow and GitHub release packaging for the fork.

### Changed

- Renamed the app product to `Whisky GPTK` / `WhiskyGPTK.app`.
- Switched bundle identifiers to neutral fork-owned identifiers under `io.whiskygptk.*`.
- Updated runtime installation to preserve auxiliary components instead of wiping the full support tree.
- Updated the project to prefer newer maintained GPTK releases over older mounted runtimes.
- Updated package dependency URLs to HTTPS for reproducible public builds.
- Updated the app help and settings surfaces with maintained repository, release, issue, and support links.

### Fixed

- Fixed bottle import and creation registration flows.
- Fixed `C:` drive opening fallback behavior.
- Fixed App Nap behavior for long-running bottle processes.
- Fixed wrapped shortcut icon handling.
- Fixed runtime reinstall behavior for `DXVK`, `winetricks`, and `verbs.txt` preservation.
- Fixed setup/download/install retry handling for runtime installation failures.
- Fixed setup and CLI wording so the app consistently refers to the GPTK runtime instead of stale WhiskyWine branding.

### Removed

- Removed redistribution of the bundled `cabextract` binary from the repository.
- Removed archived-upstream Discord, affiliate, and stale release automation references.
