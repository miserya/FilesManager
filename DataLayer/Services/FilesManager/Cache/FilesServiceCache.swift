//
//  FilesServiceCache.swift
//  DataLayer
//
//  Created by Maria Holubieva on 21.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation

protocol FilesServiceCache {

    func getFiles() -> [File]
    func append(contentsOf files: [File])
    func set(_ files: [File])
}

class FilesServiceCacheImpl: FilesServiceCache {

    @UserDefault(key: "files_manager_used_files", defaultValue: [])
    private var filesList: [File]

    func getFiles() -> [File] {
        return filesList
    }

    func append(contentsOf files: [File]) {
        filesList.append(contentsOf: files)
    }

    func set(_ files: [File]) {
        filesList = files
    }
}
