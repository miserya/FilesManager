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
        let connection = NSXPCConnection(serviceName: "com.miserya.FilesXPCService")
        connection.remoteObjectInterface = NSXPCInterface(with: FilesXPCServiceProtocol.self)
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

    func getAttributesForFiles(at pathes: [String], completion: @escaping ([NSDictionary]) -> Void) {
        filesService?.getAttributesForFiles(at: pathes, withReply: { (attributesList: [NSDictionary]) in
            completion(attributesList)
        })
    }

    func calculateHashForFiles(at pathes: [String], completion: @escaping ([String]) -> Void) {
        filesService?.getHashForFiles(at: pathes, withReply: { (hashes: [String]) in
            completion(hashes)
        })
    }

    func duplicateFiles(at pathes: [String], completion: @escaping ([String]) -> Void) {
        filesService?.duplicateFiles(at: pathes, withReply: { (duplicatesPathes: [String]) in
            completion(duplicatesPathes)
        })
    }
}
