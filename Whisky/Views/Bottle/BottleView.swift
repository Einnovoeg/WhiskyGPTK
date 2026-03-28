//
//  BottleView.swift
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

enum BottleStage {
    case config
    case programs
    case processes
}

struct BottleView: View {
    @AppStorage("useGlassUI") private var useGlassUI = true
    @ObservedObject var bottle: Bottle
    @State private var path = NavigationPath()
    @State private var programLoading: Bool = false
    @State private var showWinetricksSheet: Bool = false

    private let gridLayout = [GridItem(.adaptive(minimum: 100, maximum: .infinity))]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: useGlassUI ? 20 : 0) {
                    if useGlassUI {
                        bottleHero
                            .padding(.horizontal)
                            .padding(.top, 20)
                    }

                    pinnedProgramsSection
                        .padding(.horizontal, useGlassUI ? 16 : 0)

                    navigationLinksSection
                        .padding(.horizontal, useGlassUI ? 16 : 0)
                }
            }
            .scrollContentBackground(useGlassUI ? .hidden : .automatic)
            .bottomBar {
                HStack {
                    Spacer()
                    Button(openFolderButtonTitle) {
                        bottle.openCDrive()
                    }
                    .help(openFolderButtonHelp)
                    Button("button.terminal") {
                        bottle.openTerminal()
                    }
                    .help(terminalHelp)
                    Button("button.winetricks") {
                        showWinetricksSheet.toggle()
                    }
                    .help("Install helper components for Wine bottles.")
                    .disabled(bottle.runner != .wine || !WhiskyWineInstaller.hasWinetricksRuntime())
                    Button(primaryLaunchTitle) {
                        openRunPicker()
                    }
                    .help(primaryLaunchHelp)
                    .disabled(programLoading)
                    if programLoading {
                        Spacer()
                            .frame(width: 10)
                        ProgressView()
                            .controlSize(.small)
                    }
                }
                .padding()
            }
            .onAppear {
                updateStartMenu()
            }
            .disabled(!bottle.isAvailable)
            .navigationTitle(bottle.settings.name)
            .sheet(isPresented: $showWinetricksSheet) {
                WinetricksView(bottle: bottle)
            }
            .onChange(of: bottle.settings) { oldValue, newValue in
                guard oldValue != newValue else { return }
                // Trigger a reload
                BottleVM.shared.bottles = BottleVM.shared.bottles
            }
            .navigationDestination(for: BottleStage.self) { stage in
                switch stage {
                case .config:
                    ConfigView(bottle: bottle)
                case .programs:
                    ProgramsView(
                        bottle: bottle, path: $path
                    )
                case .processes:
                    RunningProcessesView(bottle: bottle)
                }
            }
            .navigationDestination(for: Program.self) { program in
                ProgramView(program: program)
            }
        }
    }

    private var bottleHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(bottle.settings.name)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    Text(bottle.url.lastPathComponent)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                WhiskyBrandIcon(size: 64)
            }

            ViewThatFits {
                HStack(spacing: 8) {
                    WhiskyGlassBadge(icon: bottle.runner.systemImage, title: bottle.runner.displayName, tint: .orange)
                    if bottle.runner == .wine {
                        WhiskyGlassBadge(icon: "desktopcomputer", title: bottle.settings.windowsVersion.pretty(), tint: .blue)
                        WhiskyGlassBadge(icon: bottle.settings.dxvk ? "bolt.fill" : "sparkles", title: renderLabel, tint: bottle.settings.dxvk ? .orange : .green)
                        WhiskyGlassBadge(icon: "speedometer", title: syncLabel, tint: .pink)
                    } else {
                        WhiskyGlassBadge(icon: "gamecontroller.fill", title: "DOS Games", tint: .green)
                        WhiskyGlassBadge(icon: "terminal.fill", title: bottle.settings.dosboxCycles.displayName, tint: .pink)
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    WhiskyGlassBadge(icon: bottle.runner.systemImage, title: bottle.runner.displayName, tint: .orange)
                    if bottle.runner == .wine {
                        WhiskyGlassBadge(icon: "desktopcomputer", title: bottle.settings.windowsVersion.pretty(), tint: .blue)
                        WhiskyGlassBadge(icon: bottle.settings.dxvk ? "bolt.fill" : "sparkles", title: renderLabel, tint: bottle.settings.dxvk ? .orange : .green)
                        WhiskyGlassBadge(icon: "speedometer", title: syncLabel, tint: .pink)
                    } else {
                        WhiskyGlassBadge(icon: "gamecontroller.fill", title: "DOS Games", tint: .green)
                        WhiskyGlassBadge(icon: "terminal.fill", title: bottle.settings.dosboxCycles.displayName, tint: .pink)
                    }
                }
            }

            HStack(spacing: 10) {
                Button(openFolderButtonTitle) {
                    bottle.openCDrive()
                }
                .buttonStyle(.borderedProminent)
                .help(openFolderButtonHelp)

                Button("button.terminal") {
                    bottle.openTerminal()
                }
                .buttonStyle(.bordered)
                .help(terminalHelp)

                Button("button.winetricks") {
                    showWinetricksSheet.toggle()
                }
                .buttonStyle(.bordered)
                .help("Install helper components for Wine bottles.")
                .disabled(bottle.runner != .wine || !WhiskyWineInstaller.hasWinetricksRuntime())

                Button(primaryLaunchTitle) {
                    openRunPicker()
                }
                .buttonStyle(.bordered)
                .help(primaryLaunchHelp)
            }
        }
        .whiskyGlassCard(cornerRadius: 30)
    }

    private var pinnedProgramsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            if useGlassUI {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Launch")
                        .font(.title3.weight(.semibold))
                    Text("Pinned apps and shortcuts for this bottle.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            LazyVGrid(columns: gridLayout, alignment: .center, spacing: 12) {
                ForEach(bottle.pinnedPrograms, id: \.id) { pinnedProgram in
                    PinView(
                        bottle: bottle,
                        program: pinnedProgram.program,
                        pin: pinnedProgram.pin,
                        path: $path
                    )
                }
                PinAddView(bottle: bottle)
            }
        }
        .padding(useGlassUI ? 4 : 0)
        .whiskyGlassCard(cornerRadius: useGlassUI ? 28 : 0)
    }

    private var navigationLinksSection: some View {
        Form {
            NavigationLink(value: BottleStage.programs) {
                Label("tab.programs", systemImage: "list.bullet")
            }
            NavigationLink(value: BottleStage.config) {
                Label("tab.config", systemImage: "gearshape")
            }
//            NavigationLink(value: BottleStage.processes) {
//                Label("tab.processes", systemImage: "hockey.puck.circle")
//            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
        .scrollContentBackground(useGlassUI ? .hidden : .automatic)
        .whiskyGlassCard(cornerRadius: useGlassUI ? 28 : 0)
    }

    private var renderLabel: String {
        bottle.settings.dxvk ? "DXVK Enabled" : "D3DMetal"
    }

    private var openFolderButtonTitle: LocalizedStringKey {
        bottle.runner == .wine ? "button.cDrive" : "Open DOS Games"
    }

    private var openFolderButtonHelp: String {
        bottle.runner == .wine
        ? "Open the Wine C: drive in Finder."
        : "Open the DOS Games folder mounted as drive C: in DOSBox."
    }

    private var terminalHelp: String {
        bottle.runner == .wine
        ? "Open a Terminal session with the bottle environment loaded."
        : "Open Terminal in the DOS Games folder and show the DOSBox command."
    }

    private var primaryLaunchTitle: LocalizedStringKey {
        if bottle.runner == .dosbox, bottle.settings.dosboxStartupProgram != nil {
            return "Launch Default Game"
        }
        return "button.run"
    }

    private var primaryLaunchHelp: String {
        bottle.runner == .wine
        ? "Browse for a Windows installer or executable and run it in this bottle."
        : "Launch DOSBox, optionally starting the default DOS game configured for this library."
    }

    private var syncLabel: String {
        switch bottle.settings.enhancedSync {
        case .none:
            return "No Sync Boost"
        case .esync:
            return "ESync"
        case .msync:
            return "MSync"
        }
    }

    private func updateStartMenu() {
        bottle.updateInstalledPrograms()

        guard bottle.runner == .wine else {
            return
        }

        let startMenuPrograms = bottle.getStartMenuPrograms()
        for startMenuProgram in startMenuPrograms {
            for program in bottle.programs where
            // For some godforsaken reason "foo/bar" != "foo/Bar" so...
            program.url.path().caseInsensitiveCompare(startMenuProgram.url.path()) == .orderedSame {
                program.pinned = true
                guard !bottle.settings.pins.contains(where: { $0.url == program.url }) else { return }
                bottle.settings.pins.append(PinnedProgram(
                    name: program.url.deletingPathExtension().lastPathComponent,
                    url: program.url
                ))
            }
        }
    }

    private func openRunPicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        switch bottle.runner {
        case .wine:
            panel.allowedContentTypes = [
                UTType.exe,
                UTType(exportedAs: "com.microsoft.msi-installer"),
                UTType(exportedAs: "com.microsoft.bat")
            ]
            panel.directoryURL = bottle.url.appending(path: "drive_c")
        case .dosbox:
            panel.allowedContentTypes = [
                UTType(filenameExtension: "exe") ?? .data,
                UTType(filenameExtension: "com") ?? .data,
                UTType(filenameExtension: "bat") ?? .data
            ]
            panel.directoryURL = bottle.dosGamesFolder
        }

        panel.begin { result in
            programLoading = true
            Task(priority: .userInitiated) {
                defer {
                    programLoading = false
                    updateStartMenu()
                }

                guard result == .OK, let url = panel.urls.first else {
                    return
                }

                do {
                    switch bottle.runner {
                    case .wine:
                        if url.pathExtension.lowercased() == "bat" {
                            try await Wine.runBatchFile(url: url, bottle: bottle)
                        } else {
                            try await Wine.runProgram(at: url, bottle: bottle)
                        }
                    case .dosbox:
                        try await DOSBox.run(bottle: bottle, programURL: url)
                    }
                } catch {
                    print("Failed to launch program: \(error)")
                }
            }
        }
    }
}
