//
//  MainViewModelImpl.swift
//  FilesManager
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

class MainViewModelImpl: MainViewModel {
    var filesViewItems = CurrentValueSubject<[FileViewItem], Never>([])
    var selectedFilesIndexes: [Int] = [Int]()

    private var files = [File]() {
        didSet {
            filesViewItems.send(files.map({ FileViewItem(imageName: "ImageName", name: $0.name, size: $0.size, hash: nil, location: "~/Some/path/to/folder/\($0.name)") }))
        }
    }

    init() {
    }

    //MARK: - MainViewModel

    func getFiles() {
        files = [
            File(name: "File 1", size: "115 Kb"),
            File(name: "File 2", size: "32 Mb"),
            File(name: "File 3", size: "10 Gb")
        ]
    }

    func onNeedAddFiles() {
    }

    func onNeedDeleteSelectedFiles() {
    }

    func onNeedDuplicateSelectedFiles() {
    }

    func onNeedCalculateHashForSelectedFiles() {
    }
}
