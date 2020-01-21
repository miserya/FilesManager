//
//  File+Helper.swift
//  DataLayerTests
//
//  Created by Maria Holubieva on 21.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
@testable import DataLayer

extension File {
    static func mock() -> File {
        let name = String("Name\(Int.random(in: 1...10000))")
        return File(id: UUID().uuidString,
                    name: name,
                    size: UInt64.random(in: 0...10000),
                    location: URL(fileURLWithPath: "Path/To/\(name)"),
                    hash: String(name.hashValue))
    }
}
