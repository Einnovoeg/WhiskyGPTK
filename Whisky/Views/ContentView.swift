//
//  ContentView.swift
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
import UniformTypeIdentifiers
import WhiskyKit
import SemanticVersion
import Foundation

struct ContentView: View {
    @AppStorage("selectedBottleURL") private var selectedBottleURL: URL?
    @AppStorage("checkWhiskyWineUpdates") private var checkWhiskyWineUpdates = true
    @AppStorage("autoInstallWhiskyWineUpdates") private var autoInstallWhiskyWineUpdates = true
    @AppStorage("useGlassUI") private var useGlassUI = true
    @EnvironmentObject var bottleVM: BottleVM
    @Binding var showSetup: Bool

    @State private var selected: URL?
    @State private var showBottleCreation: Bool = false
    @State private var bottlesLoaded: Bool = false
    @State private var showBottleSelection: Bool = false
    @State private var newlyCreatedBottleURL: URL?
    @State private var openedFileURL: URL?
    @State private var triggerRefresh: Bool = false
    @State private var refreshAnimation: Angle = .degrees(0)

    @State private var bottleFilter = ""

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showBottleCreation.toggle()
                } label: {
                    Image(systemName: "plus")
                        .help("button.createBottle")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    bottleVM.loadBottles()
                    if let bottle = bottleVM.bottles.first(where: { $0.url == selected }) {
                        bottle.updateInstalledPrograms()
                    }
                    triggerRefresh.toggle()
                    withAnimation(.default) {
                        refreshAnimation = .degrees(360)
                    } completion: {
                        refreshAnimation = .degrees(0)
                    }
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .help("button.refresh")
                        .rotationEffect(refreshAnimation)
                }
            }
        }
        .sheet(isPresented: $showBottleCreation) {
            BottleCreationView(newlyCreatedBottleURL: $newlyCreatedBottleURL)
        }
        .sheet(isPresented: $showSetup) {
            SetupView(showSetup: $showSetup, firstTime: false)
        }
        .sheet(item: $openedFileURL) { url in
            FileOpenView(fileURL: url,
                         currentBottle: selected,
                         bottles: bottleVM.bottles)
        }
        .onChange(of: selected) {
            selectedBottleURL = selected
        }
        .handlesExternalEvents(preferring: [], allowing: ["*"])
        .onOpenURL { url in
            openedFileURL = url
        }
        .task {
            bottleVM.loadBottles()
            bottlesLoaded = true

            if !bottleVM.bottles.isEmpty || bottleVM.countActive() != 0 {
                if let bottle = bottleVM.bottles.first(where: { $0.url == selectedBottleURL && $0.isAvailable }) {
                    selected = bottle.url
                } else {
                    selected = bottleVM.bottles[0].url
                }
            }

            if !WhiskyWineInstaller.isWhiskyWineInstalled() {
                showSetup = true
            }
            if checkWhiskyWineUpdates {
                let task = Task.detached {
                    return await WhiskyWineInstaller.shouldUpdateWhiskyWine()
                }
                let updateInfo = await task.value
                if updateInfo.0 {
                    if autoInstallWhiskyWineUpdates {
                        await installLatestRuntimeUpdate()
                        return
                    }

                    let alert = NSAlert()
                    alert.messageText = String(localized: "update.whiskywine.title")
                    alert.informativeText = String(
                        format: String(localized: "update.whiskywine.description"),
                        String(WhiskyWineInstaller.whiskyWineVersion() ?? SemanticVersion(0, 0, 0)),
                        String(updateInfo.1)
                    )
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: String(localized: "update.whiskywine.update"))
                    alert.addButton(withTitle: String(localized: "button.removeAlert.cancel"))

                    let response = alert.runModal()

                    if response == .alertFirstButtonReturn {
                        WhiskyWineInstaller.uninstall()
                        showSetup = true
                    }
                }
            }
        }
        .whiskyWindowBackground()
    }

    var sidebar: some View {
        ScrollViewReader { proxy in
            VStack(spacing: useGlassUI ? 14 : 0) {
                if useGlassUI {
                    sidebarHero
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                }

                List(selection: $selected) {
                    Section {
                        ForEach(filteredBottles) { bottle in
                            Group {
                                if bottle.inFlight {
                                    HStack(spacing: 12) {
                                        Image(systemName: "shippingbox.circle.fill")
                                            .foregroundStyle(.secondary)
                                        Text(bottle.settings.name)
                                        Spacer()
                                        ProgressView().controlSize(.small)
                                    }
                                    .opacity(0.75)
                                } else {
                                    BottleListEntry(bottle: bottle, selected: $selected, refresh: $triggerRefresh)
                                        .selectionDisabled(!bottle.isAvailable)
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(useGlassUI ? .hidden : .automatic)
                            .id(bottle.url)
                        }
                    }
                }
                .listStyle(.sidebar)
                .searchable(text: $bottleFilter, placement: .sidebar)
                .scrollContentBackground(useGlassUI ? .hidden : .automatic)
                .background {
                    if useGlassUI {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                            }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding(useGlassUI ? 14 : 0)
            }
            .animation(.default, value: bottleVM.bottles)
            .animation(.default, value: bottleFilter)
            .onChange(of: newlyCreatedBottleURL) { _, url in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    selected = url
                    withAnimation {
                        proxy.scrollTo(url, anchor: .center)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var detail: some View {
        if let bottle = selected {
            if let bottle = bottleVM.bottles.first(where: { $0.url == bottle }) {
                BottleView(bottle: bottle)
                    .disabled(bottle.inFlight)
                    .id(bottle.url)
            }
        } else {
            if (bottleVM.bottles.isEmpty || bottleVM.countActive() == 0) && bottlesLoaded {
                emptyState
            }
        }
    }

    private var sidebarHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Whisky")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    Text(currentRuntimeLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "wineglass.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.pink.gradient)
                    .padding(14)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            FlowLayout(spacing: 8) {
                WhiskyGlassBadge(
                    icon: "shippingbox.fill",
                    title: "\(bottleVM.bottles.count) Bottles",
                    tint: .orange
                )
                WhiskyGlassBadge(
                    icon: "bolt.fill",
                    title: "\(bottleVM.countActive()) Active",
                    tint: .green
                )
                WhiskyGlassBadge(
                    icon: "arrow.down.circle",
                    title: runtimeBadgeLabel,
                    tint: .blue
                )
            }

            HStack(spacing: 10) {
                Button {
                    showBottleCreation.toggle()
                } label: {
                    Label("New Bottle", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                SettingsLink {
                    Label("Settings", systemImage: "slider.horizontal.3")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .whiskyGlassCard(cornerRadius: 30)
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "wineglass")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.pink.gradient)
                .padding(18)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(spacing: 6) {
                Text("No Bottles Yet")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text("Create your first bottle to start installing Windows apps and games.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            FlowLayout(spacing: 8) {
                WhiskyGlassBadge(icon: "shippingbox", title: "Per-app bottles", tint: .orange)
                WhiskyGlassBadge(icon: "gamecontroller.fill", title: "GPTK runtime", tint: .blue)
                WhiskyGlassBadge(icon: "sparkles", title: "Glass UI", tint: .pink)
            }

            Button {
                showBottleCreation.toggle()
            } label: {
                Label("Create Bottle", systemImage: "plus")
                    .padding(.horizontal, 18)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: 420)
        .whiskyGlassCard(cornerRadius: 30)
    }

    private var runtimeBadgeLabel: String {
        WhiskyWineInstaller.whiskyWineVersion().map(String.init) ?? "Runtime Missing"
    }

    private var currentRuntimeLabel: String {
        let release = WhiskyWineInstaller.runtimeReleaseName() ?? runtimeBadgeLabel
        let source = WhiskyWineInstaller.runtimeSource() ?? "Runtime not installed"
        return "\(release) via \(source)"
    }

    var filteredBottles: [Bottle] {
        if bottleFilter.isEmpty {
            bottleVM.bottles
                .sorted()
        } else {
            bottleVM.bottles
                .filter { $0.settings.name.localizedCaseInsensitiveContains(bottleFilter) }
                .sorted()
        }
    }

    @MainActor
    private func installLatestRuntimeUpdate() async {
        guard let package = await WhiskyWineInstaller.latestRuntimePackage() else {
            return
        }

        let archiveURL: URL
        if package.downloadURL.isFileURL {
            archiveURL = package.downloadURL
        } else {
            do {
                let (downloadedURL, _) = try await URLSession(configuration: .ephemeral)
                    .download(from: package.downloadURL)
                archiveURL = downloadedURL
            } catch {
                print("Failed to download runtime update: \(error)")
                return
            }
        }

        let packageVersion = package.version
        let packageSource = package.source
        let packageReleaseName = package.releaseName
        let installed = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let installed = WhiskyWineInstaller.install(
                    from: archiveURL,
                    versionOverride: packageVersion,
                    source: packageSource,
                    releaseName: packageReleaseName
                )
                continuation.resume(returning: installed)
            }
        }

        if !installed {
            print("Failed to install runtime update.")
        }
    }
}

private struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder var content: () -> Content

    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        HStack(spacing: spacing) {
            content()
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ContentView(showSetup: .constant(false))
        .environmentObject(BottleVM.shared)
}
