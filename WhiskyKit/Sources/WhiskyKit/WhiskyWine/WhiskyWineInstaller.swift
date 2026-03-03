//
//  WhiskyWineInstaller.swift
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
import SemanticVersion

public class WhiskyWineInstaller {
    /// The Whisky application folder
    public static let applicationFolder = FileManager.default.urls(
        for: .applicationSupportDirectory, in: .userDomainMask
    )[0].appending(path: Bundle.whiskyBundleIdentifier)

    /// The folder of all the library files
    public static let libraryFolder = applicationFolder.appending(path: "Libraries")

    /// URL to the installed `wine` `bin` directory
    public static let binFolder: URL = libraryFolder.appending(path: "Wine").appending(path: "bin")

    private static let latestGPTKReleaseURL = URL(
        string: "https://api.github.com/repos/Gcenx/game-porting-toolkit/releases/latest"
    )!
    private static let legacyVersionPlistURL = URL(string: "https://data.getwhisky.app/Wine/WhiskyWineVersion.plist")!
    private static let legacyRuntimeArchiveURL = URL(string: "https://data.getwhisky.app/Wine/Libraries.tar.gz")!
    private static let session = URLSession(configuration: .ephemeral)
    private static let localVersionPlistURL = libraryFolder
        .appending(path: "WhiskyWineVersion")
        .appendingPathExtension("plist")
    private static let localRuntimeCandidates = [
        URL(fileURLWithPath: "/Applications/Game Porting Toolkit.app")
            .appending(path: "Contents")
            .appending(path: "Resources")
            .appending(path: "wine"),
        URL(fileURLWithPath: "/Volumes/Game Porting Toolkit")
            .appending(path: "Game Porting Toolkit.app")
            .appending(path: "Contents")
            .appending(path: "Resources")
            .appending(path: "wine"),
        URL(fileURLWithPath: "/Volumes/Evaluation environment for Windows games 3.0")
            .appending(path: "Game Porting Toolkit.app")
            .appending(path: "Contents")
            .appending(path: "Resources")
            .appending(path: "wine")
    ]
    private static let localRedistCandidates = [
        URL(fileURLWithPath: "/Volumes/Evaluation environment for Windows games 3.0/redist"),
        URL(fileURLWithPath: "/Volumes/Game Porting Toolkit/redist")
    ]

    public struct RuntimePackage {
        public let downloadURL: URL
        public let version: SemanticVersion
        public let source: String
        public let releaseName: String

        public init(downloadURL: URL, version: SemanticVersion, source: String, releaseName: String) {
            self.downloadURL = downloadURL
            self.version = version
            self.source = source
            self.releaseName = releaseName
        }
    }

    public static func isWhiskyWineInstalled() -> Bool {
        whiskyWineVersion() != nil
    }

    @discardableResult
    public static func install(
        from archiveURL: URL,
        versionOverride: SemanticVersion? = nil,
        source: String = "Unknown",
        releaseName: String? = nil
    ) -> Bool {
        let fileManager = FileManager.default
        let extractionFolder = fileManager.temporaryDirectory.appending(path: UUID().uuidString)
        let preservedExtrasFolder = fileManager.temporaryDirectory.appending(path: UUID().uuidString)
        let shouldCleanupArchive = shouldDeleteInstallerArtifact(at: archiveURL, fileManager: fileManager)
        var isDirectory = ObjCBool(false)
        let archiveExists = fileManager.fileExists(atPath: archiveURL.path, isDirectory: &isDirectory)
        var installSucceeded = false

        do {
            try preserveRuntimeExtrasIfNeeded(from: libraryFolder, to: preservedExtrasFolder)
            if fileManager.fileExists(atPath: libraryFolder.path) {
                try fileManager.removeItem(at: libraryFolder)
            }
            try fileManager.createDirectory(at: applicationFolder, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: libraryFolder, withIntermediateDirectories: true)

            if archiveExists && isDirectory.boolValue {
                try installRuntimePayload(from: archiveURL)
            } else {
                try fileManager.createDirectory(at: extractionFolder, withIntermediateDirectories: true)
                try Tar.untar(tarBall: archiveURL, toURL: extractionFolder)
                try installRuntimePayload(from: extractionFolder)
            }
            try applyLocalRedistOverlayIfPresent()
            try restoreRuntimeExtrasIfNeeded(from: preservedExtrasFolder)

            if let version = versionOverride {
                try saveVersion(version: version, source: source, releaseName: releaseName)
            } else if !fileManager.fileExists(atPath: localVersionPlistURL.path) {
                // Some archives only provide wine binaries and no version metadata.
                try saveVersion(version: SemanticVersion(0, 0, 0), source: source, releaseName: releaseName)
            }
            installSucceeded = true
        } catch {
            print("Failed to install WhiskyWine: \(error)")
            do {
                if !fileManager.fileExists(atPath: libraryFolder.path) {
                    try fileManager.createDirectory(at: libraryFolder, withIntermediateDirectories: true)
                }
                try restoreRuntimeExtrasIfNeeded(from: preservedExtrasFolder)
            } catch {
                print("Failed to restore preserved runtime extras: \(error)")
            }
        }

        do {
            if fileManager.fileExists(atPath: extractionFolder.path) {
                try fileManager.removeItem(at: extractionFolder)
            }
            if fileManager.fileExists(atPath: preservedExtrasFolder.path) {
                try fileManager.removeItem(at: preservedExtrasFolder)
            }
            if shouldCleanupArchive, fileManager.fileExists(atPath: archiveURL.path) {
                try fileManager.removeItem(at: archiveURL)
            }
        } catch {
            print("Failed to clean installer files: \(error)")
        }
        return installSucceeded
    }

    public static func uninstall() {
        do {
            try FileManager.default.removeItem(at: libraryFolder)
        } catch {
            print("Failed to uninstall WhiskyWine: \(error)")
        }
    }

    public static func latestRuntimePackage() async -> RuntimePackage? {
        if prefersLocalRuntime(), let package = localRuntimePackage() {
            return package
        }
        if let package = await fetchLatestGPTKPackage() {
            return package
        }
        return await fetchLegacyPackage()
    }

    public static func shouldUpdateWhiskyWine() async -> (Bool, SemanticVersion) {
        let localVersion = whiskyWineVersion()
        let remoteVersion = await latestRuntimePackage()?.version

        if let localVersion = localVersion, let remoteVersion = remoteVersion, localVersion < remoteVersion {
            return (true, remoteVersion)
        }

        return (false, SemanticVersion(0, 0, 0))
    }

    public static func whiskyWineVersion() -> SemanticVersion? {
        runtimeVersionInfo()?.version
    }

    public static func runtimeReleaseName() -> String? {
        runtimeVersionInfo()?.releaseName
    }

    public static func runtimeSource() -> String? {
        runtimeVersionInfo()?.source
    }

    public static func legacyRuntimeDownloadURL() -> URL {
        legacyRuntimeArchiveURL
    }

    public static func hasDXVKRuntime() -> Bool {
        FileManager.default.fileExists(
            atPath: libraryFolder.appending(path: "DXVK").appending(path: "x64").path
        )
    }

    public static func hasWinetricksRuntime() -> Bool {
        FileManager.default.fileExists(atPath: libraryFolder.appending(path: "winetricks").path)
    }

    public static func localRuntimePackage() -> RuntimePackage? {
        if let environmentPath = ProcessInfo.processInfo.environment["WHISKY_GPTK_LOCAL_RUNTIME_PATH"] {
            let candidate = URL(fileURLWithPath: environmentPath)
            if hasWineBinary(in: candidate) {
                return packageForLocalRuntime(at: candidate)
            }
        }

        for candidate in localRuntimeCandidates where hasWineBinary(in: candidate) {
            return packageForLocalRuntime(at: candidate)
        }

        let volumesRoot = URL(fileURLWithPath: "/Volumes")
        guard let volumeURLs = try? FileManager.default.contentsOfDirectory(
            at: volumesRoot,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return nil
        }

        for volumeURL in volumeURLs {
            let candidate = volumeURL
                .appending(path: "Game Porting Toolkit.app")
                .appending(path: "Contents")
                .appending(path: "Resources")
                .appending(path: "wine")
            if hasWineBinary(in: candidate) {
                return packageForLocalRuntime(at: candidate)
            }
        }

        return nil
    }

    private static func runtimeVersionInfo() -> WhiskyWineVersion? {
        do {
            let decoder = PropertyListDecoder()
            let data = try Data(contentsOf: localVersionPlistURL)
            return try decoder.decode(WhiskyWineVersion.self, from: data)
        } catch {
            return nil
        }
    }

    private static func fetchLatestGPTKPackage() async -> RuntimePackage? {
        guard let data = await fetchData(from: latestGPTKReleaseURL) else { return nil }

        do {
            let decoder = JSONDecoder()
            let release = try decoder.decode(GitHubRelease.self, from: data)
            guard let asset = release.assets.first(where: { asset in
                asset.name.hasPrefix("game-porting-toolkit-")
                    && (asset.name.hasSuffix(".tar.xz") || asset.name.hasSuffix(".tar.gz"))
            }), let downloadURL = URL(string: asset.browserDownloadURL) else {
                return nil
            }

            let version = parseVersion(from: [asset.name, release.tagName, release.name]) ?? SemanticVersion(0, 0, 0)
            return RuntimePackage(
                downloadURL: downloadURL,
                version: version,
                source: "Gcenx/game-porting-toolkit",
                releaseName: release.name
            )
        } catch {
            print(error)
            return nil
        }
    }

    private static func fetchLegacyPackage() async -> RuntimePackage? {
        guard let data = await fetchData(from: legacyVersionPlistURL) else { return nil }

        do {
            let decoder = PropertyListDecoder()
            let info = try decoder.decode(WhiskyWineVersion.self, from: data)
            return RuntimePackage(
                downloadURL: legacyRuntimeArchiveURL,
                version: info.version,
                source: "Whisky Legacy Runtime",
                releaseName: "WhiskyWine \(info.version)"
            )
        } catch {
            print(error)
            return nil
        }
    }

    private static func fetchData(from url: URL) async -> Data? {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 30
        if url.host == "api.github.com" {
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            request.setValue("Whisky", forHTTPHeaderField: "User-Agent")
            request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        }

        do {
            let (data, response) = try await session.data(for: request)
            if let response = response as? HTTPURLResponse,
               !(200...299).contains(response.statusCode) {
                return nil
            }
            return data
        } catch {
            print(error)
            return nil
        }
    }

    private static func saveVersion(version: SemanticVersion, source: String, releaseName: String?) throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(WhiskyWineVersion(version: version, source: source, releaseName: releaseName))
        try data.write(to: localVersionPlistURL)
    }

    private static func installRuntimePayload(from extractedArchiveURL: URL) throws {
        let fileManager = FileManager.default

        if hasWineBinary(in: extractedArchiveURL) {
            try copyWinePayload(from: extractedArchiveURL)
            return
        }

        let legacyLibrariesURL = extractedArchiveURL.appending(path: "Libraries")
        if fileManager.fileExists(atPath: legacyLibrariesURL.path) {
            try fileManager.moveItem(at: legacyLibrariesURL, to: libraryFolder)
            return
        }

        guard let winePayloadURL = locateWinePayload(in: extractedArchiveURL) else {
            throw RuntimeInstallError.unsupportedArchiveLayout
        }

        try copyWinePayload(from: winePayloadURL)
    }

    private static func locateWinePayload(in extractedArchiveURL: URL) -> URL? {
        let gptkPath = extractedArchiveURL
            .appending(path: "Game Porting Toolkit.app")
            .appending(path: "Contents")
            .appending(path: "Resources")
            .appending(path: "wine")
        if FileManager.default.fileExists(atPath: gptkPath.appending(path: "bin").appending(path: "wine64").path) {
            return gptkPath
        }

        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
        guard let enumerator = FileManager.default.enumerator(
            at: extractedArchiveURL,
            includingPropertiesForKeys: nil,
            options: options
        ) else {
            return nil
        }

        for case let url as URL in enumerator {
            guard url.lastPathComponent == "wine" else { continue }
            if FileManager.default.fileExists(atPath: url.appending(path: "bin").appending(path: "wine64").path) {
                return url
            }
        }
        return nil
    }

    private static func copyWinePayload(from source: URL) throws {
        let fileManager = FileManager.default
        let destination = libraryFolder.appending(path: "Wine")
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        try fileManager.copyItem(at: source, to: destination)
    }

    private static func applyLocalRedistOverlayIfPresent() throws {
        guard let redistURL = localRedistPath() else {
            return
        }
        let sourceLibURL = redistURL.appending(path: "lib")
        guard FileManager.default.fileExists(atPath: sourceLibURL.path) else {
            return
        }
        let destinationLibURL = libraryFolder.appending(path: "Wine").appending(path: "lib")
        try mergeDirectoryContents(from: sourceLibURL, to: destinationLibURL)
    }

    private static func localRedistPath() -> URL? {
        if let environmentPath = ProcessInfo.processInfo.environment["WHISKY_GPTK_LOCAL_REDIST_PATH"] {
            let candidate = URL(fileURLWithPath: environmentPath)
            let winePath = candidate.appending(path: "lib").appending(path: "wine")
            if FileManager.default.fileExists(atPath: winePath.path) {
                return candidate
            }
        }

        for candidate in localRedistCandidates {
            let winePath = candidate.appending(path: "lib").appending(path: "wine")
            if FileManager.default.fileExists(atPath: winePath.path) {
                return candidate
            }
        }
        return nil
    }

    private static func mergeDirectoryContents(from source: URL, to destination: URL) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: destination, withIntermediateDirectories: true)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        process.arguments = [source.path(percentEncoded: false), destination.path(percentEncoded: false)]
        let pipe = Pipe()
        process.standardError = pipe
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let message = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            throw RuntimeInstallError.copyOverlayFailed(message: message)
        }
    }

    private static func hasWineBinary(in folder: URL) -> Bool {
        FileManager.default.fileExists(atPath: folder.appending(path: "bin").appending(path: "wine64").path)
    }

    private static func packageForLocalRuntime(at localWineFolder: URL) -> RuntimePackage {
        let nameComponents = [
            localWineFolder.path(percentEncoded: false),
            localWineFolder.deletingLastPathComponent().lastPathComponent,
            localWineFolder.deletingLastPathComponent().deletingLastPathComponent().lastPathComponent
        ]
        let version = parseVersion(from: nameComponents) ?? SemanticVersion(0, 0, 0)
        return RuntimePackage(
            downloadURL: localWineFolder,
            version: version,
            source: "Local Game Porting Toolkit",
            releaseName: "Local GPTK \(version)"
        )
    }

    private static func shouldDeleteInstallerArtifact(at url: URL, fileManager: FileManager) -> Bool {
        var isDirectory = ObjCBool(false)
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory), !isDirectory.boolValue else {
            return false
        }
        return url.path.hasPrefix(fileManager.temporaryDirectory.path)
    }

    private static func prefersLocalRuntime() -> Bool {
        if let preference = UserDefaults.standard.object(forKey: "preferLocalGPTKRuntime") as? Bool {
            return preference
        }
        return true
    }

    private static func preserveRuntimeExtrasIfNeeded(from source: URL, to destination: URL) throws {
        let fileManager = FileManager.default
        let runtimeExtras = ["winetricks", "verbs.txt", "DXVK"]
        var hasAnyExtras = false

        for runtimeExtra in runtimeExtras {
            let sourceURL = source.appending(path: runtimeExtra)
            guard fileManager.fileExists(atPath: sourceURL.path) else { continue }
            if !hasAnyExtras {
                try fileManager.createDirectory(at: destination, withIntermediateDirectories: true)
                hasAnyExtras = true
            }
            try fileManager.copyItem(at: sourceURL, to: destination.appending(path: runtimeExtra))
        }
    }

    private static func restoreRuntimeExtrasIfNeeded(from source: URL) throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: source.path) else {
            return
        }
        let runtimeExtras = ["winetricks", "verbs.txt", "DXVK"]
        for runtimeExtra in runtimeExtras {
            let sourceURL = source.appending(path: runtimeExtra)
            let destinationURL = libraryFolder.appending(path: runtimeExtra)
            guard fileManager.fileExists(atPath: sourceURL.path),
                  !fileManager.fileExists(atPath: destinationURL.path) else {
                continue
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
        }
    }

    private static func parseVersion(from strings: [String]) -> SemanticVersion? {
        for string in strings {
            if let version = parseVersion(from: string) {
                return version
            }
        }
        return nil
    }

    private static func parseVersion(from string: String) -> SemanticVersion? {
        guard let regex = try? NSRegularExpression(pattern: #"(\d+)\.(\d+)(?:[.-](\d+))?"#) else {
            return nil
        }
        let range = NSRange(string.startIndex..<string.endIndex, in: string)
        guard let match = regex.firstMatch(in: string, options: [], range: range) else {
            return nil
        }

        func value(_ index: Int) -> Int? {
            guard index < match.numberOfRanges else { return nil }
            let range = match.range(at: index)
            guard range.location != NSNotFound, let swiftRange = Range(range, in: string) else { return nil }
            return Int(string[swiftRange])
        }

        guard let major = value(1), let minor = value(2) else { return nil }
        let patch = value(3) ?? 0
        return SemanticVersion(major, minor, patch)
    }

    private struct GitHubRelease: Codable {
        let tagName: String
        let name: String
        let assets: [GitHubAsset]

        enum CodingKeys: String, CodingKey {
            case tagName = "tag_name"
            case name
            case assets
        }
    }

    private struct GitHubAsset: Codable {
        let name: String
        let browserDownloadURL: String

        enum CodingKeys: String, CodingKey {
            case name
            case browserDownloadURL = "browser_download_url"
        }
    }

    private enum RuntimeInstallError: Error {
        case unsupportedArchiveLayout
        case copyOverlayFailed(message: String)
    }
}

struct WhiskyWineVersion: Codable {
    var version: SemanticVersion = SemanticVersion(1, 0, 0)
    var source: String = "Whisky"
    var releaseName: String?

    enum CodingKeys: String, CodingKey {
        case version
        case source
        case releaseName
    }

    init(version: SemanticVersion = SemanticVersion(1, 0, 0), source: String = "Whisky", releaseName: String? = nil) {
        self.version = version
        self.source = source
        self.releaseName = releaseName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decodeIfPresent(SemanticVersion.self, forKey: .version) ?? SemanticVersion(1, 0, 0)
        source = try container.decodeIfPresent(String.self, forKey: .source) ?? "Whisky"
        releaseName = try container.decodeIfPresent(String.self, forKey: .releaseName)
    }
}
