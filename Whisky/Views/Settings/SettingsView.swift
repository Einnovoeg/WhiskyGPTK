//
//  SettingsView.swift
//  Whisky
//
//  This file is part of Whisky.
//
//  Whisky is free software: you can redistribute it and/or modify it under the terms
//  of the GNU General Public License as published by the Free Software Foundation,
//  either version 3 of the License, or (at your option) any later version.
//
//  Whisky is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//  See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with Whisky.
//  If not, see https://www.gnu.org/licenses/.
//

import SwiftUI
import WhiskyKit

struct SettingsView: View {
    @AppStorage("SUEnableAutomaticChecks") var whiskyUpdate = true
    @AppStorage("killOnTerminate") var killOnTerminate = true
    @AppStorage("checkWhiskyWineUpdates") var checkWhiskyWineUpdates = true
    @AppStorage("autoInstallWhiskyWineUpdates") var autoInstallWhiskyWineUpdates = true
    @AppStorage("preferLocalGPTKRuntime") var preferLocalGPTKRuntime = true
    @AppStorage("useGlassUI") var useGlassUI = true
    @AppStorage("disableAppNap") var disableAppNap = true
    @AppStorage("wrapProgramShortcuts") var wrapProgramShortcuts = true
    @AppStorage("defaultBottleLocation") var defaultBottleLocation = BottleData.defaultBottleDir
    @State private var latestRuntimePackage: WhiskyWineInstaller.RuntimePackage?
    @State private var latestRuntimeSummary = String(
        localized: "settings.runtime.checking",
        defaultValue: "Checking latest runtime..."
    )
    @State private var runtimeActionMessage: String?
    @State private var isRefreshingRuntime = false
    @State private var isInstallingRuntime = false
    private let hasAppUpdateFeed: Bool = {
        guard let feedURL = Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String else {
            return false
        }
        return !feedURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }()
    private var runtimeSummary: String {
        let version = WhiskyWineInstaller.whiskyWineVersion().map(String.init) ?? String(
            localized: "settings.runtime.notInstalled",
            defaultValue: "Not installed"
        )
        let source = WhiskyWineInstaller.runtimeSource() ?? String(
            localized: "settings.runtime.unknownSource",
            defaultValue: "Unknown source"
        )
        return "\(version) · \(source)"
    }

    var body: some View {
        Form {
            Section("settings.general") {
                Toggle("settings.toggle.kill.on.terminate", isOn: $killOnTerminate)
                Toggle(
                    String(
                        localized: "settings.toggle.appNap",
                        defaultValue: "Prevent App Nap to improve stability"
                    ),
                    isOn: $disableAppNap
                )
                .onChange(of: disableAppNap) { _, isDisabled in
                    WhiskyActivityController.shared.setAppNapDisabled(isDisabled)
                }
                ActionView(
                    text: "settings.path",
                    subtitle: defaultBottleLocation.prettyPath(),
                    actionName: "create.browse"
                ) {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = true
                    panel.directoryURL = BottleData.containerDir
                    panel.begin { result in
                        if result == .OK, let url = panel.urls.first {
                            defaultBottleLocation = url
                        }
                    }
                }
            }
            Section {
                Toggle(
                    String(localized: "settings.toggle.glass", defaultValue: "Use glass effects"),
                    isOn: $useGlassUI
                )
                Toggle(
                    String(
                        localized: "settings.toggle.wrapShortcuts",
                        defaultValue: "Wrap shortcut icons with Whisky styling"
                    ),
                    isOn: $wrapProgramShortcuts
                )
            } header: {
                Text(String(localized: "settings.appearance", defaultValue: "Appearance"))
            }
            Section("settings.updates") {
                if hasAppUpdateFeed {
                    Toggle("settings.toggle.whisky.updates", isOn: $whiskyUpdate)
                } else {
                    Text(String(localized: "settings.appfeed.unconfigured",
                                defaultValue: "App update feed is not configured for this build."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Toggle("settings.toggle.whiskywine.updates", isOn: $checkWhiskyWineUpdates)
                Toggle(
                    String(localized: "settings.toggle.whiskywine.autoInstall",
                           defaultValue: "Automatically install runtime updates"),
                    isOn: $autoInstallWhiskyWineUpdates
                )
                .disabled(!checkWhiskyWineUpdates)
                Toggle(
                    String(localized: "settings.toggle.runtime.preferLocal",
                           defaultValue: "Prefer local mounted GPTK runtime"),
                    isOn: $preferLocalGPTKRuntime
                )
                Text(
                    String(
                        format: String(
                            localized: "settings.runtime.installed",
                            defaultValue: "Installed Runtime: %@"
                        ),
                        runtimeSummary
                    )
                )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(
                    String(
                        format: String(
                            localized: "settings.runtime.latest",
                            defaultValue: "Latest Available: %@"
                        ),
                        latestRuntimeSummary
                    )
                )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let runtimeActionMessage {
                    Text(runtimeActionMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Button(
                        String(
                            localized: "settings.runtime.checkNow",
                            defaultValue: "Check Now"
                        )
                    ) {
                        Task {
                            await refreshLatestRuntime()
                        }
                    }
                    .disabled(isRefreshingRuntime || isInstallingRuntime)

                    Button(isInstallingRuntime
                           ? String(localized: "settings.runtime.installing", defaultValue: "Installing…")
                           : String(localized: "settings.runtime.installNow", defaultValue: "Install Latest Runtime")) {
                        Task {
                            await installLatestRuntime()
                        }
                    }
                    .disabled(isRefreshingRuntime || isInstallingRuntime || latestRuntimePackage == nil)
                }
            }
        }
        .formStyle(.grouped)
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: ViewWidth.medium)
        .task {
            await refreshLatestRuntime()
        }
    }

    @MainActor
    private func refreshLatestRuntime() async {
        isRefreshingRuntime = true
        defer { isRefreshingRuntime = false }

        let package = await WhiskyWineInstaller.latestRuntimePackage()
        latestRuntimePackage = package
        latestRuntimeSummary = package.map { "\($0.version) · \($0.source)" } ?? String(
            localized: "settings.runtime.unavailable",
            defaultValue: "Unable to resolve latest runtime"
        )
    }

    @MainActor
    private func installLatestRuntime() async {
        if latestRuntimePackage == nil {
            await refreshLatestRuntime()
        }

        guard let package = latestRuntimePackage else {
            runtimeActionMessage = String(
                localized: "settings.runtime.installUnavailable",
                defaultValue: "Runtime download source is unavailable."
            )
            return
        }

        isInstallingRuntime = true
        runtimeActionMessage = nil

        let archiveURL: URL
        if package.downloadURL.isFileURL {
            archiveURL = package.downloadURL
        } else {
            do {
                let (downloadedURL, _) = try await URLSession(configuration: .ephemeral)
                    .download(from: package.downloadURL)
                archiveURL = downloadedURL
            } catch {
                isInstallingRuntime = false
                runtimeActionMessage = String(
                    localized: "settings.runtime.downloadFailed",
                    defaultValue: "Failed to download the selected runtime."
                )
                return
            }
        }

        let packageVersion = package.version
        let packageSource = package.source
        let packageReleaseName = package.releaseName
        let success = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let success = WhiskyWineInstaller.install(
                    from: archiveURL,
                    versionOverride: packageVersion,
                    source: packageSource,
                    releaseName: packageReleaseName
                )
                continuation.resume(returning: success)
            }
        }

        isInstallingRuntime = false
        runtimeActionMessage = success
            ? String(
                localized: "settings.runtime.installSuccess",
                defaultValue: "Installed %@."
            )
            .replacingOccurrences(of: "%@", with: package.releaseName)
            : String(
                localized: "settings.runtime.installFailed",
                defaultValue: "Runtime installation failed."
            )
        await refreshLatestRuntime()
    }
}

#Preview {
    SettingsView()
}
