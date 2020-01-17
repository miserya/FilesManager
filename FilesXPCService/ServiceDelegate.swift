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
        newConnection.exportedInterface = NSXPCInterface(with: FilesXPCServiceProtocol.self)
        let exportedObject = FilesXPCService()
        newConnection.exportedObject = exportedObject
        newConnection.resume()

        return true
    }
}
