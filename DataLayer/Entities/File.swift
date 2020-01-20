//
//  File.swift
//  FilesManager
//
//  Created by Maria Holubieva on 13.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation

public struct File: Codable {

    public let id: String
    public let name: String
    public let size: UInt64
    public let hash: String?
    public let location: URL

    public init(id: String, name: String, size: UInt64, location: URL, hash: String? = nil) {
        self.id = id
        self.name = name
        self.size = size
        self.hash = hash
        self.location = location
    }

    public mutating func update(hash: String) {
        self = File(id: self.id, name: self.name, size: self.size, location: self.location, hash: hash)
    }
}
