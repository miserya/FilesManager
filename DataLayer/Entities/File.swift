//
//  File.swift
//  FilesManager
//
//  Created by Maria Holubieva on 13.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation

public struct File {
    
    public let name: String
    public let size: String

    public init(name: String, size: String) {
        self.name = name
        self.size = size
    }
}
