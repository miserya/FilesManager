//
//  FileEntity.swift
//  XPCSupport
//
//  Created by Maria Holubieva on 20.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation

public class FileEntity: NSObject, NSSecureCoding {

    private enum CodingKeys: String {
        case id = "id"
        case path = "path"
    }

    public static var supportsSecureCoding: Bool { true }

    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: CodingKeys.id.rawValue)
        coder.encode(path, forKey: CodingKeys.path.rawValue)
    }

    public required init?(coder: NSCoder) {
        self.id = coder.decodeObject(forKey: CodingKeys.id.rawValue) as? String ?? ""
        self.path = coder.decodeObject(forKey: CodingKeys.path.rawValue) as? String ?? ""
    }

    public let id: String
    public let path: String

    public init(id: String, path: String) {
        self.id = id
        self.path = path
    }
}
