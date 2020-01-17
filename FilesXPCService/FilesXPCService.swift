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

    public func getHashForFiles(at pathes: [String], withReply reply: @escaping ([String]) -> Void) {
        let url = pathes.compactMap({ URL(fileURLWithPath: $0) })
        var hashes = [String]()
        let dispathchGroup = DispatchGroup()
        url.forEach { (url: URL) in
            dispathchGroup.enter()
            concurrentQueue.async { [weak self] in
                if let hash: String = self?.sha256(url: url)?.map({ String(format: "%02hhx", $0) }).joined() {
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

    func sha256(url: URL) -> Data? {
        do {
            let bufferSize = 1024 * 1024
            // Open file for reading:
            let file = try FileHandle(forReadingFrom: url)
            defer {
                file.closeFile()
            }

            // Create and initialize SHA256 context:
            var context = CC_SHA256_CTX()
            CC_SHA256_Init(&context)

            // Read up to `bufferSize` bytes, until EOF is reached, and update SHA256 context:
            while autoreleasepool(invoking: {
                // Read up to `bufferSize` bytes
                let data = file.readData(ofLength: bufferSize)
                if data.count > 0 {
                    data.withUnsafeBytes {
                        _ = CC_SHA256_Update(&context, $0, numericCast(data.count))
                    }
                    // Continue
                    return true
                } else {
                    // End of file
                    return false
                }
            }) { }

            // Compute the SHA256 digest:
            var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
            digest.withUnsafeMutableBytes {
                _ = CC_SHA256_Final($0, &context)
            }

            return digest
        } catch {
            print(error)
            return nil
        }
    }
}
