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

    var error = PassthroughSubject<Error?, Never>()

    private(set) var filesViewItems = CurrentValueSubject<[FileViewItem], Never>([])
    private(set) var isFilesActionsEnabled = CurrentValueSubject<Bool, Never>(false)
    private(set) var isOpenPanelShowed = CurrentValueSubject<Bool, Never>(false)

    private(set) var isLoading = CurrentValueSubject<Bool, Never>(false)
    private(set) var progressMaxValue = CurrentValueSubject<Double, Never>(100)
    private(set) var progressValue = CurrentValueSubject<Double, Never>(0)

    private let progressIndicator = ProgressIndicator()

    private let stateStorage = MainViewModelStateStorage()

    private let getFilesUseCase = GetFiles()
    private let addFilesUseCase = AddFiles()
    private let removeFilesUseCase = RemoveFiles()
    private let duplicateFilesUseCase = DuplicateFiles()
    private let calculateHashUseCase = CalculateHash()

    private var getFilesList: AnyCancellable?
    private var addNewFiles: AnyCancellable?
    private var removeFiles: AnyCancellable?
    private var calculateHash: AnyCancellable?
    private var duplicateFiles: AnyCancellable?

    private var subscriptions = [AnyCancellable]()

    init() {
        progressIndicator.$currentProgress
            .sink(receiveCompletion: { _ in }) { [weak self] (value: Double) in
                self?.progressValue.send(value) }
            .store(in: &subscriptions)
    }

    //MARK: - MainViewModel

    func setSelectedFilesIndexes( _ newIndexes: [Int]) {
        stateStorage.selectedFilesIndexes = newIndexes
        isFilesActionsEnabled.send(!stateStorage.selectedFilesIndexes.isEmpty)
    }

    func getFiles() {
        getFilesList?.cancel()
        isLoading.send(true)

        getFilesList = getFilesUseCase
            .execute(with: ())
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                guard let self = self else { return }
                self.isLoading.send(false)

                switch completion {
                case .finished:             break
                case .failure(let error):   self.error.send(error)

                } }, receiveValue: { [weak self] (filesList: [File]) in
                    guard let self = self else { return }
                    self.updateFilesList(with: filesList)
            })
    }

    func startImportFilesAction() {
        isOpenPanelShowed.send(true)
    }

    func endImportFilesAction() {
        isOpenPanelShowed.send(false)
    }

    func addFiles(at urls: [URL]) {
        guard !isLoading.value else { return }

        addNewFiles?.cancel()
        progressIndicator.reset()
        isLoading.send(true)

        addNewFiles = addFilesUseCase
            .execute(with: urls, progress: progressIndicator)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                guard let self = self else { return }
                self.isLoading.send(false)

                switch completion {
                case .finished:             break
                case .failure(let error):   self.error.send(error)

                } }, receiveValue: { [weak self] _ in
                    self?.getFiles()
            })
    }

    func onNeedDeleteSelectedFiles() {
        guard !isLoading.value else { return }

        removeFiles?.cancel()
        progressIndicator.reset()
        isLoading.send(true)

        let filesToDelete = stateStorage.getSelectedFiles()

        removeFiles = removeFilesUseCase
            .execute(with: filesToDelete, progress: progressIndicator)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                guard let self = self else { return }
                self.isLoading.send(false)

                switch completion {
                case .finished:             self.setSelectedFilesIndexes([])
                case .failure(let error):   self.error.send(error)

                } }, receiveValue: { [weak self] _ in
                    self?.getFiles()
            })
    }

    func onNeedDuplicateSelectedFiles() {
        guard !isLoading.value else { return }

        duplicateFiles?.cancel()
        progressIndicator.reset()
        isLoading.send(true)
        let filesToDuplicate = stateStorage.getSelectedFiles()

        duplicateFiles = duplicateFilesUseCase
            .execute(with: filesToDuplicate, progress: progressIndicator)
            .flatMap({ [weak self] (newPathes: [String]) in
                return (self?.addFilesUseCase.execute(with: newPathes.compactMap({ return URL(fileURLWithPath: $0) })) ?? PassthroughSubject<Void, Error>().eraseToAnyPublisher())
            })
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                guard let self = self else { return }
                self.isLoading.send(false)

                switch completion {
                case .finished:             self.setSelectedFilesIndexes([])
                case .failure(let error):   self.error.send(error)

                } }, receiveValue: { [weak self] _ in
                    self?.getFiles()
            })
    }

    func onNeedCalculateHashForSelectedFiles() {
        guard !isLoading.value else { return }
        
        calculateHash?.cancel()
        progressIndicator.reset()
        isLoading.send(true)

        let selectedFilesList = stateStorage.getSelectedFiles()

        calculateHash = calculateHashUseCase
            .execute(with: selectedFilesList, progress: progressIndicator)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                guard let self = self else { return }
                self.isLoading.send(false)

                switch completion {
                case .finished:             self.setSelectedFilesIndexes([])
                case .failure(let error):   self.error.send(error)

                } }, receiveValue: { [weak self] (filesWithHash: [File]) in
                    guard let self = self else { return }
                    self.applyHashes(filesWithHash, toFilesAt: self.stateStorage.selectedFilesIndexes)
            })
    }

    //MARK: - Private

    private func applyHashes(_ filesWithHash: [File], toFilesAt indexes: [Int]) {
        var currentFiles = stateStorage.files
        for file in filesWithHash {
            if let hash = file.hash, let index = currentFiles.firstIndex(where: { $0.id == file.id }) {
                currentFiles[index].update(hash: hash)
            }
        }
        updateFilesList(with: currentFiles)
    }

    private func updateFilesList(with files: [File]) {
        stateStorage.files = files
        filesViewItems.send(stateStorage.getViewItems())
    }
}
