//
//  MainViewModelStateStorage.swift
//  FilesManager
//
//  Created by Maria Holubieva on 21.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import Combine
import DataLayer
import Cocoa

class MainViewModelStateStorage {

    var files = [File]()

    var selectedFilesIndexes: [Int] = [Int]()

    private let mapper = FilesDataMapper()

    func getViewItems() -> [FileViewItem] {
        return mapper.map(files)
    }

    func getSelectedFiles() -> [File] {
        return selectedFilesIndexes.map({ return files[$0] })
    }
}
