//
//  FilesXPCServiceProtocol.swift
//  XPCSupport
//
//  Created by Maria Holubieva on 17.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation

@objc public protocol FilesXPCServiceProtocol {

    func getHashForFiles(at pathes: [String], withReply reply: @escaping ([String]) -> Void)
}
