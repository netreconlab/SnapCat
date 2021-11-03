//
//  Utility.swift
//  SnapCat
//
//  Created by Corey Baker on 7/3/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import ParseSwift
import os.log
import UIKit

struct Utility {

    static func fetchImage(_ file: ParseFile?) async -> UIImage? {
        let defaultImage = UIImage(systemName: "camera")
        guard let file = file,
              let fileManager = ParseFileManager(),
              let defaultDirectoryPath = fileManager.defaultDataDirectoryPath else {
            return defaultImage
        }
        let downloadDirectoryPath = defaultDirectoryPath
            .appendingPathComponent(Constants.fileDownloadsDirectory, isDirectory: true)
        let fileLocation = downloadDirectoryPath.appendingPathComponent(file.name).relativePath
        if FileManager.default.fileExists(atPath: fileLocation) {
            guard let image = UIImage(contentsOfFile: fileLocation) else {
                do {
                    let image = try await file.fetch(options: [.cachePolicy(.useProtocolCachePolicy)])
                    if let path = image.localURL?.relativePath,
                       let image = UIImage(contentsOfFile: path) {
                        return image
                    } else {
                        return defaultImage
                    }
                } catch {
                    Logger.home.error("Error fetching picture: \(error.localizedDescription)")
                    return defaultImage
                }
            }
            return image
        } else {
            guard let path = file.localURL?.relativePath,
                  let image = UIImage(contentsOfFile: path) else {
                      do {
                          let image = try await file.fetch()
                          if let path = image.localURL?.relativePath,
                                let image = UIImage(contentsOfFile: path) {
                              return image
                          } else {
                              return defaultImage
                          }
                    } catch {
                        Logger.home.error("Error fetching picture: \(error.localizedDescription)")
                        return defaultImage
                    }
            }
            return image
        }
    }

    static func getFileNameFromPath(_ path: String?) -> String {
        guard let filePath = path else {
            return ""
        }
        let path = URL(fileURLWithPath: filePath, isDirectory: false)
        return path.lastPathComponent
    }

    static func removeFilesAtDirectory(_ originalPath: String, isDirectory: Bool) throws {
        var path = URL(fileURLWithPath: originalPath, isDirectory: true)
        if !isDirectory {
            var pathArray = originalPath.components(separatedBy: "/")
            pathArray.removeFirst()
            pathArray.removeLast()
            path = URL(fileURLWithPath: "")
            pathArray.forEach {
                path.appendPathComponent($0, isDirectory: true)
            }
        }

        let contents = try FileManager.default.contentsOfDirectory(atPath: path.path)
        if contents.count == 0 {
            return
        }
        try contents.forEach {
            let filePath = path.appendingPathComponent($0)
            try FileManager.default.removeItem(at: filePath)
        }
    }
}
