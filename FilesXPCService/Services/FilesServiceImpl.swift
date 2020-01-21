//
//  FilesServiceImpl.swift
//  FilesXPCService
//
//  Created by Maria Holubieva on 20.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import XPCSupport

class FilesServiceImpl: FilesService {

    private let fileManager = FileManager.default
    private let hasher = MD5Hasher()

    func getAttributesForFile(_ file: FileEntity) -> Result<FileAttributes, Error> {
        do {
            let attributes = try NSDictionary(dictionary: fileManager.attributesOfItem(atPath: file.path))
            let result = FileAttributes(id: file.id, attributes: attributes)
            return .success(result)

        } catch {
            return .failure(error)
        }
    }

    func duplicateFile(at path: String) -> Result<String, Error> {
        do {
            let sourceURL = URL(fileURLWithPath: path)

            let pathExtension = sourceURL.pathExtension
            var fileName = sourceURL.lastPathComponent.replacingOccurrences(of: ".\(pathExtension)", with: "")

            var destinationURL = sourceURL
                .deletingLastPathComponent()
                .appendingPathComponent(fileName)
                .appendingPathExtension(pathExtension)
            
            while self.fileManager.fileExists(atPath: destinationURL.path) {
                fileName.append("-copy")
                destinationURL = sourceURL
                    .deletingLastPathComponent()
                    .appendingPathComponent(fileName)
                    .appendingPathExtension(pathExtension)
            }

            try self.fileManager.copyItem(at: sourceURL, to: destinationURL)
            return .success(destinationURL.path)

        } catch {
            return .failure(error)
        }
    }

    func calculateHashForFile(_ file: FileEntity) -> Result<FileHash, Error> {
        let url = URL(fileURLWithPath: file.path)
        
        if let hash: String = hasher.sha256(url: url)?.map({ String(format: "%02hhx", $0) }).joined() {
            let result = FileHash(id: file.id, md5Hash: hash)
            return .success(result)

        } else {
            return .failure(FilesXPCServiceError.invalidHash(file.path))
        }
    }
}
