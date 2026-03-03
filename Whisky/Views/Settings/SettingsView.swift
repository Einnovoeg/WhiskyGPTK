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
    @AppStorage("useGlassUI") var useGlassUI = false
    @AppStorage("defaultBottleLocation") var defaultBottleLocation = BottleData.defaultBottleDir
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
            }
        }
        .formStyle(.grouped)
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: ViewWidth.medium)
    }
}

#Preview {
    SettingsView()
}
