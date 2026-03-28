//
//  BottleCreationView.swift
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

struct BottleCreationView: View {
    @Binding var newlyCreatedBottleURL: URL?

    @State private var newBottleName: String = ""
    @State private var newBottleVersion: WinVersion = .win10
    @State private var newBottleRunner: BottleRunner = .wine
    @State private var newBottleURL: URL = UserDefaults.standard.url(forKey: "defaultBottleLocation")
                                           ?? BottleData.defaultBottleDir
    @State private var nameValid: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("create.name", text: $newBottleName)
                    .onChange(of: newBottleName) { _, name in
                        nameValid = !name.isEmpty
                    }
                    .help("Choose the library name shown in the sidebar.")

                Picker("Runner", selection: $newBottleRunner) {
                    ForEach(BottleRunner.allCases, id: \.self) { runner in
                        Label(runner.displayName, systemImage: runner.systemImage)
                            .tag(runner)
                    }
                }
                .help("Select the runtime family for this library.")

                VStack(alignment: .leading, spacing: 6) {
                    Text(newBottleRunner.creationSummary)
                        .font(.subheadline)
                    if newBottleRunner == .dosbox {
                        Text("DOSBox libraries scan the DOS Games folder for .exe, .com, and .bat files.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Picker("create.win", selection: $newBottleVersion) {
                    ForEach(WinVersion.allCases.reversed(), id: \.self) {
                        Text($0.pretty())
                    }
                }
                .disabled(newBottleRunner != .wine)
                .help(newBottleRunner == .wine
                      ? "Choose the Windows version reported to apps in this GPTK bottle."
                      : "DOSBox libraries do not emulate a Windows version.")

                ActionView(
                    text: "create.path",
                    subtitle: newBottleURL.prettyPath(),
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
                            newBottleURL = url
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("create.title")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("create.cancel") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                    .help("Close this sheet without creating a new library.")
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("create.create") {
                        submit()
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!nameValid)
                    .help("Create the new GPTK Wine bottle or DOSBox library.")
                }
            }
            .onSubmit {
                submit()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: ViewWidth.small)
    }

    func submit() {
        newlyCreatedBottleURL = BottleVM.shared.createNewBottle(bottleName: newBottleName,
                                                                winVersion: newBottleVersion,
                                                                runner: newBottleRunner,
                                                                bottleURL: newBottleURL)
        dismiss()
    }
}

#Preview {
    BottleCreationView(newlyCreatedBottleURL: .constant(nil))
}
