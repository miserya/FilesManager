//
//  MockFilesServiceCache.swift
//  DataLayerTests
//
//  Created by Maria Holubieva on 21.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
@testable import DataLayer

class MockFilesServiceCache: FilesServiceCache {
    var mockFiles = [File]()

    func getFiles() -> [File] {
        return mockFiles
    }

    func append(contentsOf files: [File]) {
        mockFiles.append(contentsOf: files)
    }

    func set(_ files: [File]) {
        mockFiles = files
    }
}
