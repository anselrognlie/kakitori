//
//  KvgLoaderView.swift
//  StepperApp
//
//  Created by Ansel Rognlie on 8/31/22.
//

import SwiftUI
import UIKit
import ZIPFoundation

struct Preferences: Codable {
    var defaultKanjiVGUrl: String
}

struct KvgLoaderView: View {
    @State var msg: String?

    // https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }

    func getKanjiVGPath() -> URL {
        return getDocumentsDirectory().appendingPathComponent("kanjivg")
    }

    func getKanjiVGArchivePath() -> URL {
        return getDocumentsDirectory().appendingPathComponent("kanjivg.zip")
    }

    func saveData(_ data: Data, to: URL) throws {
        let url = to

        try data.write(to: url, options: [.atomic])
    }

    func loadProps() -> String? {
        if let path = Bundle.main.path(forResource: "Preferences", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path),
           let preferences = try? PropertyListDecoder().decode(Preferences.self, from: xml)
        {
            print(preferences.defaultKanjiVGUrl)
            return preferences.defaultKanjiVGUrl
        }

        return nil
    }

    // https://www.hackingwithswift.com/example-code/system/how-to-read-the-contents-of-a-directory-using-filemanager
    func listFiles() {
        let fm = FileManager.default

        do {
            let items = try fm.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil)

            for item in items {
                print("Found \(item.absoluteString)")
            }

            msg = items.map { $0.absoluteString}.joined(separator: "\n")
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
    }

    func unzipArchiveAsync(_ url: URL) async {
        let task = Task {
            let fileManager = FileManager.default
            let sourceURL = url
            let destinationURL = getKanjiVGPath()
            do {
                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                try fileManager.unzipItem(at: sourceURL, to: destinationURL)
            } catch {
                print("Extraction of ZIP archive failed with error:\(error)")
            }
        }

        await task.value
    }

    func doesDirExist(url: URL) -> Bool {
        var isDir: ObjCBool = true
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        return exists && isDir.boolValue
    }

    func doesFileExist(url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }

    func deleteFile(url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }

    func loadUrl() async throws {
        print("loading")

        if doesDirExist(url: getKanjiVGPath()) {
            msg = "already loaded"
            return
        }

        let zipUrl = getKanjiVGArchivePath()
        if !doesFileExist(url: zipUrl) {
            guard let urlPath = loadProps(),
                  let url = URL(string: urlPath) else { return }

            let request = URLRequest(url: url)
            msg = "Loading data from: \(url.absoluteString)"

            let (tempUrl, _) = try await URLSession.shared.download(for: request)
            try FileManager.default.copyItem(at: tempUrl, to: zipUrl)
            msg = "Unzipping new archive"
        } else {
            msg = "Unzipping already downloaded archive"
        }

        await unzipArchiveAsync(zipUrl)
        try deleteFile(url:zipUrl)
        msg = "Complete"
    }


    var body: some View {
        Text(msg ?? "Hello, World!")
        .task {
            do {
                try await loadUrl()
            } catch {
                msg = "Error loading url: \(error)"
            }
        }
    }
}

struct KvgLoaderView_Previews: PreviewProvider {
    static var previews: some View {
        KvgLoaderView()
    }
}
