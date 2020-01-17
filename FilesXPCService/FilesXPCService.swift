//
//  FilesService.swift
//  FilesXPCService
//
//  Created by Maria Holubieva on 17.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import XPCSupport
import CommonCrypto

public class FilesXPCService: NSObject, FilesXPCServiceProtocol {

    private let fileManager = FileManager.default

    let concurrentQueue = DispatchQueue(label: "com.miserya.Concurrent", attributes: .concurrent)

    public func getAttributesForFiles(at pathes: [String], withReply reply: @escaping ([NSDictionary]) -> Void) {

        var attributesList = [NSDictionary]()

        let dispathchGroup = DispatchGroup()
        pathes.forEach { (path: String) in

            dispathchGroup.enter()
            concurrentQueue.async { [weak self] in
                guard let self = self else { return }

                do {
                    let attributes = try NSDictionary(dictionary: self.fileManager.attributesOfItem(atPath: path))
                    attributesList.append(attributes)

                } catch {
                    print("Cannot copy item \(error.localizedDescription)")
                }

                dispathchGroup.leave()
            }
        }

        dispathchGroup.notify(queue: DispatchQueue.global()) {
            reply(attributesList)
        }

    }

    public func getHashForFiles(at pathes: [String], withReply reply: @escaping ([String]) -> Void) {
        let url = pathes.compactMap({ URL(fileURLWithPath: $0) })
        var hashes = [String]()

        let dispathchGroup = DispatchGroup()
        url.forEach { (url: URL) in

            dispathchGroup.enter()
            concurrentQueue.async {
                if let hash: String = MD5Hasher().sha256(url: url)?.map({ String(format: "%02hhx", $0) }).joined() {
                    hashes.append(hash)
                } else {
                    hashes.append("")
                }

                dispathchGroup.leave()
            }
        }
        dispathchGroup.notify(queue: DispatchQueue.global()) {
            reply(hashes)
        }
    }

    public func duplicateFiles(at pathes: [String], withReply reply: @escaping ([String]) -> Void) {

        var newPathes = [String]()

        let dispathchGroup = DispatchGroup()
        pathes.forEach { (path: String) in

            dispathchGroup.enter()
            concurrentQueue.async { [weak self] in
                guard let self = self else { return }

                do {
                    if let url = URL(string: path) {
                        var newFileName = url.lastPathComponent
                        if self.fileManager.fileExists(atPath: path) {
                            newFileName.append("-copy")
                        }
                        let destinationURL = url.deletingLastPathComponent().appendingPathExtension(newFileName)
                        try self.fileManager.copyItem(at: url, to: destinationURL)
                        newPathes.append(destinationURL.path)
                    }
                } catch {
                    print("Cannot copy item \(error.localizedDescription)")
                }

                dispathchGroup.leave()
            }
        }

        dispathchGroup.notify(queue: DispatchQueue.global()) {
            reply(newPathes)
        }
    }
}
