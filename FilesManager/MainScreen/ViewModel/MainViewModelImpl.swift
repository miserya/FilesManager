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

    private(set) var filesViewItems = CurrentValueSubject<[FileViewItem], Never>([])
    var selectedFilesIndexes: [Int] = [Int]() {
        didSet {
            isFilesActionsEnabled.send(!selectedFilesIndexes.isEmpty) 
        }
    }
    var error = PassthroughSubject<Error?, Never>()
    private(set) var isFilesActionsEnabled = CurrentValueSubject<Bool, Never>(false)
    private(set) var isOpenPanelShowed = CurrentValueSubject<Bool, Never>(false)

    private(set) var isLoading = CurrentValueSubject<Bool, Never>(false)
    private(set) var progressMaxValue = CurrentValueSubject<Double, Never>(100)
    private(set) var progressValue = CurrentValueSubject<Double, Never>(0)
    private let progressIndicator = ProgressIndicator()

    private var files = [File]() {
        didSet {
            filesViewItems.send(files.map({
                FileViewItem(image: NSWorkspace.shared.icon(forFile: $0.location.path),
                             name: $0.name,
                             size: ByteCountFormatter().string(fromByteCount: Int64($0.size)),
                             hash: $0.hash,
                             location: $0.location.path) }))
        }
    }

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

    func getFiles() {
        getFilesList?.cancel()
        isLoading.send(true)

        getFilesList = getFilesUseCase
            .execute(with: ())
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                self?.isLoading.send(false)
                if case .failure(let error) = completion {
                    self?.error.send(error)

                } }, receiveValue: { [weak self] (filesList: [File]) in
                    self?.isLoading.send(false)
                    self?.files = filesList
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
                self?.isLoading.send(false)
                if case .failure(let error) = completion {
                    self?.error.send(error)

                } }, receiveValue: { [weak self] _ in
                    self?.getFiles()
                    self?.isLoading.send(false)
            })
    }

    func onNeedDeleteSelectedFiles() {
        guard !isLoading.value else { return }

        removeFiles?.cancel()
        progressIndicator.reset()
        isLoading.send(true)

        let filesToDelete = selectedFilesIndexes.map({ return files[$0] })

        removeFiles = removeFilesUseCase
            .execute(with: filesToDelete, progress: progressIndicator)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                self?.isLoading.send(false)
                if case .failure(let error) = completion {
                    self?.error.send(error)

                } }, receiveValue: { [weak self] _ in
                    self?.getFiles()
                    self?.isLoading.send(false)
            })
    }

    func onNeedDuplicateSelectedFiles() {
        guard !isLoading.value else { return }

        duplicateFiles?.cancel()
        progressIndicator.reset()
        isLoading.send(true)
        let filesToDuplicate = selectedFilesIndexes.map({ return files[$0] })

        duplicateFiles = duplicateFilesUseCase
            .execute(with: filesToDuplicate, progress: progressIndicator)
            .flatMap({ [weak self] (newPathes: [String]) in
                return (self?.addFilesUseCase.execute(with: newPathes.compactMap({ return URL(fileURLWithPath: $0) })) ?? PassthroughSubject<Void, Error>().eraseToAnyPublisher())
            })
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                self?.isLoading.send(false)
                if case .failure(let error) = completion {
                    self?.error.send(error)

                } }, receiveValue: { [weak self] _ in
                    self?.getFiles()
                    self?.isLoading.send(false)
            })
    }

    func onNeedCalculateHashForSelectedFiles() {
        guard !isLoading.value else { return }
        
        calculateHash?.cancel()
        progressIndicator.reset()
        isLoading.send(true)

        let selectedFilesList = selectedFilesIndexes.map({ return files[$0] })

        calculateHash = calculateHashUseCase
            .execute(with: selectedFilesList, progress: progressIndicator)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                self?.isLoading.send(false)
                if case .failure(let error) = completion {
                self?.error.send(error)

                } }, receiveValue: { [weak self] (filesWithHash: [File]) in
                    guard let self = self else { return }
                    self.isLoading.send(false)
                    self.applyHashes(filesWithHash, toFilesAt: self.selectedFilesIndexes)
            })
    }

    //MARK: - Private

    private func applyHashes(_ filesWithHash: [File], toFilesAt indexes: [Int]) {
        var currentFiles = files
        for file in filesWithHash {
            if let hash = file.hash, let index = currentFiles.firstIndex(where: { $0.id == file.id }) {
                currentFiles[index].update(hash: hash)
            }
        }
        files = currentFiles
    }
}
