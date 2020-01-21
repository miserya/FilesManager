//
//  FilesServiceImpl.swift
//  DataLayer
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

class FilesServiceImpl: FilesService {

    private let filesCache: FilesServiceCache
    private var serviceManager: FilesXPCServiceManager

    init(serviceManager: FilesXPCServiceManager, cache: FilesServiceCache) {
        self.serviceManager = serviceManager
        self.filesCache = cache
    }

    func getFiles() -> AnyPublisher<[File], Error> {
        return Publishers.Sequence(sequence: [ filesCache.getFiles() ]).eraseToAnyPublisher()
    }

    func add(filesAt urls: [URL], progress: ProgressIndicator?) -> AnyPublisher<Void, Error> {
        let publisher = PassthroughSubject<Void, Error>()

        serviceManager.updateProgress = { [weak progress = progress] (value) in
            progress?.currentProgress = value
        }
        serviceManager.errorHandler = { (error) in
            publisher.send(completion: Subscribers.Completion<Error>.failure(error))
        }
        serviceManager.getAttributesForFiles(at: urls.map({ $0.path })) { [weak self] (files: [File], error: Error?) in

            if let error = error {
                publisher.send(completion: Subscribers.Completion<Error>.failure(error))

            } else {
                self?.filesCache.append(contentsOf: files)
                publisher.send(())
            }
            publisher.send(completion: .finished)
        }

        return publisher.eraseToAnyPublisher()
    }

    func remove(files: [File], progress: ProgressIndicator?) -> AnyPublisher<Void, Error> {
        var deletedFilesCount: Double = 0
        var filesList = filesCache.getFiles()
        filesList.removeAll { (file: File) -> Bool in
            return files.contains(where: { [weak progress = progress] (fileToDelete: File) in
                if fileToDelete.location == file.location {
                    deletedFilesCount += 1
                    progress?.currentProgress = (deletedFilesCount/Double(files.count))*100.0
                    return true
                }
                return false
            })
        }
        filesCache.set(filesList)

        return Publishers.Sequence(sequence: [()]).eraseToAnyPublisher()
    }

    func duplicate(files: [File], progress: ProgressIndicator?) -> AnyPublisher<[String], Error> {
        let publisher = PassthroughSubject<[String], Error>()

        serviceManager.updateProgress = { [weak progress = progress] (value) in
            progress?.currentProgress = value
        }
        serviceManager.errorHandler = { (error) in
            publisher.send(completion: Subscribers.Completion<Error>.failure(error))
        }
        serviceManager.duplicateFiles(at: files.map({ $0.location.path })) { (newPathes: [String], error: Error?) in
            if let error = error {
                publisher.send(completion: Subscribers.Completion<Error>.failure(error))

            } else {
                publisher.send(newPathes)
            }
            publisher.send(completion: .finished)
        }
        return publisher.eraseToAnyPublisher()
    }

    func calculateHash(for files: [File], progress: ProgressIndicator?) -> AnyPublisher<[File], Error> {

        let publisher = PassthroughSubject<[File], Error>()

        serviceManager.updateProgress = { [weak progress = progress] (value) in
            progress?.currentProgress = value
        }
        serviceManager.errorHandler = { (error) in
            publisher.send(completion: Subscribers.Completion<Error>.failure(error))
        }
        serviceManager.calculateHashForFiles(files) { (updatedFiles: [File], error: Error?) in
            if let error = error {
                publisher.send(completion: Subscribers.Completion<Error>.failure(error))

            } else {
                publisher.send(updatedFiles)
            }
            publisher.send(completion: .finished)
        }

        return publisher.eraseToAnyPublisher()
    }

}
