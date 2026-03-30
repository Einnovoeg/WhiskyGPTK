# Changelog

All notable changes to this project will be documented in this file.

The format is loosely based on Keep a Changelog and versioned with Semantic Versioning.

## [Unreleased]

## [3.4.0] - 2026-03-29

### Added

- Added curated compatibility presets for Windows games, launchers, utilities, blank Wine bottles, blank DOS libraries, and classic DOS games.
- Added preset-first bottle creation so new libraries start from a known-good recipe instead of a flat manual form.
- Added preset reapply support in each bottle's `Config` tab and preset visibility in bottle details and CLI listings.
- Added `WhiskyCmd create --preset ...` support so CLI users can create bottles from the same compatibility model as the GUI.

### Changed

- Reworked the bottle creation sheet so the preset and core library fields are primary while advanced overrides stay collapsed until needed.
- Kept the main window quiet by placing compatibility retuning in the `Config` tab rather than adding more top-level controls.

### Fixed

- Fixed bottle metadata persistence so the last applied preset now survives reloads and can be inspected later.
- Fixed the mismatch between GUI creation defaults and CLI creation defaults by routing both through the same preset model.

## [3.3.0] - 2026-03-29

### Added

- Added a runner health scan in Settings so the app can inspect Rosetta, Wine runtime, DOSBox, Homebrew availability, and the recommended stability defaults for this Mac.
- Added selectable Wine runtime channels for `Managed GPTK Runtime`, `Wine 11 Stable`, `Wine Devel`, and `Wine Staging`.
- Added Homebrew-backed DOSBox install/update actions directly in the Settings `Runners` tab.

### Changed

- Reworked the Settings `Runners` tab into a compact runner-management surface instead of a static status dump.
- Updated bottle creation copy so new Windows libraries reflect the currently selected Wine runtime.
- Updated sidebar runtime summaries to reflect the active runtime channel instead of assuming GPTK-only state.

### Fixed

- Fixed Wine tool launching so external Homebrew Wine builds can use native helper binaries such as `winecfg` and `regedit`.
- Fixed bottle metadata so discovered Wine versions are no longer reset back to the historical `7.7` default.
- Fixed runner-status reporting so DOSBox install guidance now includes the current latest Homebrew version.

## [3.2.1] - 2026-03-29

### Changed

- Reworked the main window hierarchy so the sidebar, overview, and library pages now follow a consistent macOS management layout.
- Replaced the oversized decorative header treatment with compact library panels and a restrained default appearance.
- Moved primary library actions back above the fold so common tasks are visible without scrolling.
- Reorganized global controls into tabbed Settings sections for `General`, `Appearance`, `Runners`, `Updates`, and `Resources`.
- Standardized panel styling across the sidebar, overview cards, quick-launch tiles, and setup surfaces.

### Fixed

- Fixed the sidebar summary so runtime and library statistics no longer collapse into unreadable vertical stacks.
- Fixed the bottle overview so it no longer duplicates controls or buries the actionable tools section behind decorative content.
- Fixed the Settings window layout so long option lists no longer overflow a single flat form.
- Fixed quick-launch tiles to render with consistent card styling whether glass effects are enabled or disabled.
- Fixed the runtime auto-update install path to avoid capturing a non-Sendable runtime package across threads.

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
