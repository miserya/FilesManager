//
//  FilesXPCServiceProtocol.swift
//  XPCSupport
//
//  Created by Maria Holubieva on 17.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation

@objc public protocol FilesXPCServiceProtocol {

    func getAttributesForFiles(at pathes: [FileEntity], withReply reply: @escaping ([FileAttributes], Error?) -> Void)

    func getHashForFiles(_ files: [FileEntity], withReply reply: @escaping ([FileHash], Error?) -> Void)

    func duplicateFiles(at pathes: [String], withReply reply: @escaping ([String], Error?) -> Void)
}
