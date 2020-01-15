//
//  MainViewModelImpl.swift
//  FilesManager
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine
import DataLayer
import Cocoa

class MainViewModelImpl: MainViewModel {
    var filesViewItems = CurrentValueSubject<[FileViewItem], Never>([])
    var selectedFilesIndexes: [Int] = [Int]() {
        didSet {
            isFilesActionsEnabled.send(!selectedFilesIndexes.isEmpty) 
        }
    }
    var error = PassthroughSubject<Error?, Never>()
    var isFilesActionsEnabled = CurrentValueSubject<Bool, Never>(false)
    var isOpenPanelShowed = CurrentValueSubject<Bool, Never>(false)

    private var files = [File]()

    private var getFilesList: AnyCancellable?
    private var addNewFiles: AnyCancellable?
    private var removeFiles: AnyCancellable?

    init() {
    }

    //MARK: - MainViewModel

    func getFiles() {
        getFilesList?.cancel()
        getFilesList = GetFiles()
            .execute(with: ())
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                if case .failure(let error) = completion {
                    self?.error.send(error)

                } }, receiveValue: { [weak self] (filesList: [File]) in
                    self?.files = filesList
                    self?.filesViewItems.send(filesList.map({
                        FileViewItem(image: NSWorkspace.shared.icon(forFile: $0.location.path),
                                     name: $0.name,
                                     size: ByteCountFormatter().string(fromByteCount: Int64($0.size)),
                                     hash: nil,
                                     location: $0.location.path) }))
            })
    }

    func startImportFilesAction() {
        isOpenPanelShowed.send(true)
    }

    func endImportFilesAction() {
        isOpenPanelShowed.send(false)
    }

    func addFiles(at urls: [URL]) {
        addNewFiles?.cancel()
        addNewFiles = AddFiles()
            .execute(with: urls)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                if case .failure(let error) = completion {
                    self?.error.send(error)

                } }, receiveValue: { [weak self] _ in
                    self?.getFiles()
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

                } }, receiveValue: { [weak self] _ in
                    self?.getFiles()
            })
    }

    func onNeedDuplicateSelectedFiles() {
        debugPrint("TODO")
    }

    func onNeedCalculateHashForSelectedFiles() {
        debugPrint("TODO")
    }
}
