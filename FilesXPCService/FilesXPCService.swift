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
                    newPathes.append(destinationURL.path)

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
