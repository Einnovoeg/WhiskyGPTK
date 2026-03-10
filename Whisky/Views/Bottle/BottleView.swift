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
                    Button("button.cDrive") {
                        bottle.openCDrive()
                    }
                    Button("button.terminal") {
                        bottle.openTerminal()
                    }
                    Button("button.winetricks") {
                        showWinetricksSheet.toggle()
                    }
                    .disabled(!WhiskyWineInstaller.hasWinetricksRuntime())
                    Button("button.run") {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = false
                        panel.canChooseDirectories = false
                        panel.canChooseFiles = true
                        panel.allowedContentTypes = [UTType.exe,
                                                     UTType(exportedAs: "com.microsoft.msi-installer"),
                                                     UTType(exportedAs: "com.microsoft.bat")]
                        panel.directoryURL = bottle.url.appending(path: "drive_c")
                        panel.begin { result in
                            programLoading = true
                            Task(priority: .userInitiated) {
                                if result == .OK {
                                    if let url = panel.urls.first {
                                        do {
                                            if url.pathExtension == "bat" {
                                                try await Wine.runBatchFile(url: url, bottle: bottle)
                                            } else {
                                                try await Wine.runProgram(at: url, bottle: bottle)
                                            }
                                        } catch {
                                            print("Failed to run external program: \(error)")
                                        }
                                        programLoading = false
                                    }
                                } else {
                                    programLoading = false
                                }
                                updateStartMenu()
                            }
                        }
                    }
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

                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.orange.gradient)
                    .padding(14)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }

            ViewThatFits {
                HStack(spacing: 8) {
                    WhiskyGlassBadge(icon: "desktopcomputer", title: bottle.settings.windowsVersion.pretty(), tint: .blue)
                    WhiskyGlassBadge(icon: bottle.settings.dxvk ? "bolt.fill" : "sparkles", title: renderLabel, tint: bottle.settings.dxvk ? .orange : .green)
                    WhiskyGlassBadge(icon: "speedometer", title: syncLabel, tint: .pink)
                }
                VStack(alignment: .leading, spacing: 8) {
                    WhiskyGlassBadge(icon: "desktopcomputer", title: bottle.settings.windowsVersion.pretty(), tint: .blue)
                    WhiskyGlassBadge(icon: bottle.settings.dxvk ? "bolt.fill" : "sparkles", title: renderLabel, tint: bottle.settings.dxvk ? .orange : .green)
                    WhiskyGlassBadge(icon: "speedometer", title: syncLabel, tint: .pink)
                }
            }

            HStack(spacing: 10) {
                Button("button.cDrive") {
                    bottle.openCDrive()
                }
                .buttonStyle(.borderedProminent)

                Button("button.terminal") {
                    bottle.openTerminal()
                }
                .buttonStyle(.bordered)

                Button("button.winetricks") {
                    showWinetricksSheet.toggle()
                }
                .buttonStyle(.bordered)
                .disabled(!WhiskyWineInstaller.hasWinetricksRuntime())
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
}
