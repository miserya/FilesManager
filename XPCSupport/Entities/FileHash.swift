//
//  FileHash.swift
//  XPCSupport
//
//  Created by Maria Holubieva on 20.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation

public class FileHash: NSObject, NSSecureCoding {

    private enum CodingKeys: String {
        case id = "id"
        case md5Hash = "md5Hash"
    }

    public static var supportsSecureCoding: Bool { true }

    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: CodingKeys.id.rawValue)
        coder.encode(md5Hash, forKey: CodingKeys.md5Hash.rawValue)
    }

    public required init?(coder: NSCoder) {
        self.id = coder.decodeObject(forKey: CodingKeys.id.rawValue) as? String ?? ""
        self.md5Hash = coder.decodeObject(forKey: CodingKeys.md5Hash.rawValue) as? String ?? ""
    }

    public let id: String
    public let md5Hash: String

    public init(id: String, md5Hash: String) {
        self.id = id
        self.md5Hash = md5Hash
    }
}
