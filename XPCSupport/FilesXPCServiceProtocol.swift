//
//  FilesXPCServiceProtocol.swift
//  XPCSupport
//
//  Created by Maria Holubieva on 17.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation

@objc public protocol FilesXPCServiceProtocol {

    func getAttributesForFiles(at pathes: [String], withReply reply: @escaping ([NSDictionary], Error?) -> Void)

    func getHashForFiles(at pathes: [String], withReply reply: @escaping ([String], Error?) -> Void)

    func duplicateFiles(at pathes: [String], withReply reply: @escaping ([String], Error?) -> Void)
}
