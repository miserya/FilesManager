//
//  MainViewModelImpl.swift
//  FilesManager
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine
import DataLayer

class MainViewModelImpl: MainViewModel {
    var filesViewItems = CurrentValueSubject<[FileViewItem], Never>([])
    var selectedFilesIndexes: [Int] = [Int]()
    var error = PassthroughSubject<Error?, Never>()

    private var files = [File]() {
        didSet {
            filesViewItems.send(files.map({ FileViewItem(imageName: "ImageName", name: $0.name, size: $0.size, hash: nil, location: "~/Some/path/to/folder/\($0.name)") }))
        }
    }

    private var addNewFiles: AnyCancellable?
    private var removeFiles: AnyCancellable?

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
        addNewFiles?.cancel()
        addNewFiles = AddNewFiles()
            .execute(with: ())
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                if case .failure(let error) = completion {
                    self?.error.send(error)

                } }, receiveValue: { [weak self] (newFilesList: [File]) in
                    self?.files.append(contentsOf: newFilesList)
            })
    }

    func onNeedDeleteSelectedFiles() {
        removeFiles?.cancel()

        let filesToDelete = selectedFilesIndexes.map({ return files[$0] })

        removeFiles = RemoveFiles()
            .execute(with: filesToDelete)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                if case .failure(let error) = completion {
                    self?.error.send(error)

                } }, receiveValue: { [weak self] (newFilesList: [File]) in
                    self?.files = newFilesList
            })
    }

    func onNeedDuplicateSelectedFiles() {
        debugPrint("TODO")
    }

    func onNeedCalculateHashForSelectedFiles() {
        debugPrint("TODO")
    }
}
