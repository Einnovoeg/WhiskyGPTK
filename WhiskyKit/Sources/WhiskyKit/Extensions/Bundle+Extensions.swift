//
//  Bundle+Extension.swift
//  WhiskyKit
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

public extension Bundle {
    static var whiskyBundleIdentifier: String {
        if let environmentOverride = ProcessInfo.processInfo.environment["WHISKY_BUNDLE_ID_OVERRIDE"]?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !environmentOverride.isEmpty {
            return environmentOverride
        }

        let currentIdentifier = Bundle.main.bundleIdentifier ?? "com.isaacmarovitz.Whisky"
        if hasStoredData(for: currentIdentifier) {
            return currentIdentifier
        }

        let alternates = ["com.isaacmarovitz.Whisky", "com.isaacmarovitz.WhiskyGPTK"]
            .filter { $0 != currentIdentifier }
        for candidate in alternates where hasStoredData(for: candidate) {
            return candidate
        }

        return currentIdentifier
    }

    private static func hasStoredData(for bundleIdentifier: String) -> Bool {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let containers = fileManager.homeDirectoryForCurrentUser
            .appending(path: "Library")
            .appending(path: "Containers")

        return fileManager.fileExists(atPath: appSupport.appending(path: bundleIdentifier).path)
            || fileManager.fileExists(atPath: containers.appending(path: bundleIdentifier).path)
    }
}
