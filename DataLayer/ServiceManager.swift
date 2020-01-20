//
//  ServiceManager.swift
//  DataLayer
//
//  Created by Maria Holubieva on 16.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import XPCSupport

class ServiceManager {
    static var shared = ServiceManager()

    var errorHandler: ((Error) -> Void)?

    private var filesService: FilesXPCServiceProtocol?
    private lazy var connection: NSXPCConnection = {
        let interface = NSXPCInterface(with: FilesXPCServiceProtocol.self)
        let outputSet = NSSet(objects: FileHash.self, FileAttributes.self, NSData.self, NSDate.self, NSDictionary.self, NSNumber.self, NSNull.self, NSOrderedSet.self, NSSet.self, NSArray.self, NSString.self) as! Set<AnyHashable>
        interface.setClasses(outputSet, for: #selector(FilesXPCServiceProtocol.getAttributesForFiles(at:withReply:)), argumentIndex: 0, ofReply: true)
        interface.setClasses(outputSet, for: #selector(FilesXPCServiceProtocol.getHashForFile(_:withReply:)), argumentIndex: 0, ofReply: true)

        let connection = NSXPCConnection(serviceName: "com.miserya.FilesXPCService")
        connection.remoteObjectInterface = interface
        return connection
    }()

    init() {
        connection.resume()

        connection.interruptionHandler = {
            debugPrint("interruptionHandler")
        }
        connection.invalidationHandler = {
            debugPrint("invalidationHandler")
        }

        let defaultErrorHandler: ((Error) -> Void) = { (error) in debugPrint("XPC connection ERROR: \(error.localizedDescription)") }

        guard let xpcService = connection.remoteObjectProxyWithErrorHandler(errorHandler ?? defaultErrorHandler) as? FilesXPCServiceProtocol else {
                self.errorHandler?(DataLayerError.unableToSetupXPCConnection(connection))
                return
        }

        filesService = xpcService
    }

    deinit {
        connection.invalidate()
    }

    func getAttributesForFiles(at pathes: [String], completion: @escaping ([File], Error?) -> Void) {
        let args = pathes.map({ FileEntity(id: UUID().uuidString, path: $0) })

        filesService?.getAttributesForFiles(at: args, withReply: { (attributesList: [FileAttributes], error: Error?) in
            var files = [File]()
            for attr in attributesList {
                if let entity = args.first(where: { $0.id == attr.id }) {
                    let url = URL(fileURLWithPath: entity.path)
                    files.append(File(id: UUID().uuidString, name: url.lastPathComponent, size: attr.attributes.fileSize(), location: url))
                }
            }

            completion(files, error)
        })
    }

//    func calculateHashForFiles(at pathes: [String], completion: @escaping ([String], Error?) -> Void) {
//        filesService?.getHashForFiles(at: pathes, withReply: { (hashes: [String], error: Error?) in
//            completion(hashes, error)
//        })
//    }

    func calculateHashForFile(_ file: File, completion: @escaping (File?, Error?) -> Void) {
        filesService?.getHashForFile(FileEntity(id: file.id, path: file.location.path), withReply: { (hash: FileHash?, error: Error?) in
            var fileCopy = file
            fileCopy.update(hash: hash?.md5Hash ?? "")
            completion(fileCopy, error)
        })
    }

    func duplicateFiles(at pathes: [String], completion: @escaping ([String], Error?) -> Void) {
        filesService?.duplicateFiles(at: pathes, withReply: { (duplicatesPathes: [String], error: Error?) in
            completion(duplicatesPathes, error)
        })
    }
}
