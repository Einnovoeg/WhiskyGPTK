//
//  BottleVM.swift
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

import Foundation
import SemanticVersion
import WhiskyKit

// swiftlint:disable:next todo
// TODO: Don't use unchecked!
final class BottleVM: ObservableObject, @unchecked Sendable {
    @MainActor static let shared = BottleVM()

    var bottlesList = BottleData()
    @Published var bottles: [Bottle] = []

    @MainActor
    func loadBottles() {
        bottles = bottlesList.loadBottles()
    }

    func countActive() -> Int {
        return bottles.filter { $0.isAvailable == true }.count
    }

    func createNewBottle(bottleName: String, winVersion: WinVersion, bottleURL: URL) -> URL {
        let newBottleDir = bottleURL.appending(path: UUID().uuidString)

        Task.detached {
            var bottleId: Bottle?
            do {
                try FileManager.default.createDirectory(atPath: newBottleDir.path(percentEncoded: false),
                                                        withIntermediateDirectories: true)
                let bottle = Bottle(bottleUrl: newBottleDir, inFlight: true)
                bottleId = bottle
                bottle.settings.name = bottleName
                bottle.settings.windowsVersion = winVersion

                await MainActor.run {
                    self.bottlesList.registerBottlePath(newBottleDir)
                    self.bottles.append(bottle)
                }

                try await Wine.changeWinVersion(bottle: bottle, win: winVersion)
                do {
                    let wineVer = try await Wine.wineVersion()
                    bottle.settings.wineVersion = SemanticVersion(wineVer) ?? SemanticVersion(0, 0, 0)
                } catch {
                    print("Failed to determine bottle wine version: \(error)")
                }

                await MainActor.run {
                    self.loadBottles()
                }
            } catch {
                print("Failed to create new bottle: \(error)")
                let metadataURL = newBottleDir.appending(path: "Metadata").appendingPathExtension("plist")
                let fileManager = FileManager.default
                let keepBottle = fileManager.fileExists(atPath: newBottleDir.path(percentEncoded: false))
                    || fileManager.fileExists(atPath: metadataURL.path(percentEncoded: false))

                await MainActor.run {
                    if keepBottle {
                        self.bottlesList.registerBottlePath(newBottleDir)
                        self.loadBottles()
                    } else if let bottle = bottleId {
                        if let index = self.bottles.firstIndex(of: bottle) {
                            self.bottles.remove(at: index)
                        }
                        self.bottlesList.removeBottlePath(newBottleDir)
                    }
                }
            }
        }
        return newBottleDir
    }
}
