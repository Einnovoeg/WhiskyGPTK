# Changelog

All notable changes to this project will be documented in this file.

The format is loosely based on Keep a Changelog and versioned with Semantic Versioning.

## [Unreleased]

## [3.2.0] - 2026-03-28

### Added

- Added AppleScript-safe command escaping for Terminal launch flows and CLI installation.
- Added clearer concurrency comments around `@unchecked Sendable` model types used by detached tasks.
- Added tooltip coverage for creation, setup, process-management, program-menu, and file-open UI flows.

### Changed

- Updated project metadata to publish from the new `Einnovoeg/WhiskyGPTK` repository.
- Updated release, issue, and documentation links to the new repository location.
- Updated shortcut launcher generation to use tighter executable permissions.

### Fixed

- Fixed DOSBox Staging config generation to use current `mouse_capture`, `glshader`, and `cpu_cycles` settings instead of stale options.
- Fixed a command-injection risk where quotes and backslashes could break Terminal AppleScript command strings.
- Fixed terminal command generation so user-provided program arguments and environment values are shell-escaped before generating launch commands.

## [3.1.0] - 2026-03-24

### Added

- Added a dual-runner model so libraries can target either GPTK Wine or DOSBox Staging.
- Added DOSBox Staging detection, per-library configuration, and DOS game discovery for `.exe`, `.com`, and `.bat` files.
- Added DOSBox controls in the bottle creation flow, bottle settings, and global Settings runner panel.
- Added runner-aware CLI output and bottle creation with `whisky create --runner`.

### Changed

- Updated the main window to present Whisky GPTK as a broader macOS game launcher rather than a Wine-only bottle manager.
- Updated bottle detail views, quick actions, and sidebar badges to show runner-specific state and actions.
- Updated external file-opening flows so runner choice is explicit.

### Fixed

- Fixed the app startup path so a valid DOSBox-only install no longer forces GPTK setup immediately.
- Fixed runtime availability checks so DOSBox libraries are marked unavailable only when the DOSBox runtime is actually missing.
- Fixed documentation drift by clarifying how Wine 11.0 upstream changes map to macOS support in this fork.

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
