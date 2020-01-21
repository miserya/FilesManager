//
//  ServiceDelegate.swift
//  FilesXPCService
//
//  Created by Maria Holubieva on 17.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import XPCSupport

class ServiceDelegate: NSObject, NSXPCListenerDelegate {

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        let interface = NSXPCInterface(with: FilesXPCServiceProtocol.self)
        let inputSet = NSSet(objects: FileEntity.self, NSArray.self, NSString.self) as! Set<AnyHashable>
        interface.setClasses(inputSet, for: #selector(FilesXPCServiceProtocol.getAttributesForFiles(at:withReply:)), argumentIndex: 0, ofReply: false)
        interface.setClasses(inputSet, for: #selector(FilesXPCServiceProtocol.getHashForFiles(_:withReply:)), argumentIndex: 0, ofReply: false)

        newConnection.exportedInterface = interface

        newConnection.remoteObjectInterface = NSXPCInterface(with: FilesXPCProgress.self)
        newConnection.exportedObject = FilesXPCService(remoteObjectProxy: newConnection.remoteObjectProxy as! FilesXPCProgress)

        newConnection.resume()

        return true
    }
}
