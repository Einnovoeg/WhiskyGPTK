//
//  BottleListEntry.swift
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
import UniformTypeIdentifiers

struct BottleListEntry: View {
    @AppStorage("useGlassUI") private var useGlassUI = true
    let bottle: Bottle
    @Binding var selected: URL?
    @Binding var refresh: Bool

    @State private var showBottleRename: Bool = false
    @State private var name: String = ""

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill((isSelected && useGlassUI) ? Color.white.opacity(0.16) : Color.white.opacity(useGlassUI ? 0.08 : 0.0))
                    .frame(width: 36, height: 36)
                Image(systemName: bottle.isAvailable ? "wineglass.fill" : "externaldrive.badge.xmark")
                    .foregroundStyle(bottle.isAvailable ? Color.pink : Color.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(bottle.settings.windowsVersion.pretty())
                    Text(bottle.settings.dxvk ? "DXVK" : "D3DMetal")
                    if bottle.settings.avxEnabled {
                        Text("AVX")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if isSelected && useGlassUI {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            if useGlassUI {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.16) : Color.white.opacity(0.05))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(isSelected ? 0.18 : 0.08), lineWidth: 1)
                    }
            }
        }
            .opacity(bottle.isAvailable ? 1.0 : 0.5)
            .onChange(of: refresh, initial: true) {
                name = bottle.settings.name
            }
            .sheet(isPresented: $showBottleRename) {
                RenameView("rename.bottle.title", name: name) { newName in
                    name = newName
                    bottle.rename(newName: newName)
                }
            }
            .contextMenu {
                Button("button.rename", systemImage: "pencil.line") {
                    showBottleRename.toggle()
                }
                .disabled(!bottle.isAvailable)
                .labelStyle(.titleAndIcon)
                Button("button.removeAlert", systemImage: "trash") {
                    showRemoveAlert(bottle: bottle)
                }
                .labelStyle(.titleAndIcon)
                Divider()
                Button("button.moveBottle", systemImage: "shippingbox.and.arrow.backward") {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = true
                    panel.begin { result in
                        if result == .OK {
                            if let url = panel.urls.first {
                                let newBottePath = url
                                    .appending(path: bottle.url.lastPathComponent)

                                bottle.move(destination: newBottePath)
                                selected = newBottePath
                            }
                        }
                    }
                }
                .disabled(!bottle.isAvailable)
                .labelStyle(.titleAndIcon)
                Button("button.exportBottle", systemImage: "arrowshape.turn.up.right") {
                    let panel = NSSavePanel()
                    panel.canCreateDirectories = true
                    panel.allowedContentTypes = [UTType.gzip]
                    panel.allowsOtherFileTypes = false
                    panel.isExtensionHidden = false
                    panel.nameFieldStringValue = bottle.settings.name + ".tar"
                    panel.begin { result in
                        if result == .OK {
                            if let url = panel.url {
                                Task.detached(priority: .background) {
                                    bottle.exportAsArchive(destination: url)
                                }
                            }
                        }
                    }
                }
                .disabled(!bottle.isAvailable)
                .labelStyle(.titleAndIcon)
                Divider()
                Button("button.showInFinder", systemImage: "folder") {
                    NSWorkspace.shared.activateFileViewerSelecting([bottle.url])
                }
                .disabled(!bottle.isAvailable)
                .labelStyle(.titleAndIcon)
            }
    }

    private var isSelected: Bool {
        selected == bottle.url
    }

    func showRemoveAlert(bottle: Bottle) {
        let checkbox = NSButton(checkboxWithTitle: String(localized: "button.removeAlert.checkbox"),
                                target: self, action: nil)
        let alert = NSAlert()
        alert.messageText = String(format: String(localized: "button.removeAlert.msg"),
                                   bottle.settings.name)
        alert.informativeText = String(localized: "button.removeAlert.info")
        alert.alertStyle = .warning
        let delete = alert.addButton(withTitle: String(localized: "button.removeAlert.delete"))
        delete.hasDestructiveAction = true
        alert.addButton(withTitle: String(localized: "button.removeAlert.cancel"))
        if bottle.isAvailable {
            alert.accessoryView = checkbox
        }

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            Task(priority: .userInitiated) {
                if selected == bottle.url {
                    selected = nil
                }

                bottle.remove(delete: checkbox.state == .on)
            }
        }
    }
}

#Preview {
    BottleListEntry(
        bottle: Bottle(bottleUrl: URL(filePath: "")),
        selected: .constant(nil),
        refresh: .constant(false)
    )
}
