//
//  FileAttributes.swift
//  XPCSupport
//
//  Created by Maria Holubieva on 20.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation

public class FileAttributes: NSObject, NSSecureCoding {

    private enum CodingKeys: String {
        case id = "id"
        case attributes = "attributes"
    }

    public static var supportsSecureCoding: Bool { true }

    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: CodingKeys.id.rawValue)
        coder.encode(attributes, forKey: CodingKeys.attributes.rawValue)
    }

    public required init?(coder: NSCoder) {
        self.id = coder.decodeObject(forKey: CodingKeys.id.rawValue) as? String ?? ""
        self.attributes = coder.decodeObject(forKey: CodingKeys.attributes.rawValue) as? NSDictionary ?? NSDictionary()
    }

    public let id: String
    public let attributes: NSDictionary

    public init(id: String, attributes: NSDictionary) {
        self.id = id
        self.attributes = attributes
    }
}
