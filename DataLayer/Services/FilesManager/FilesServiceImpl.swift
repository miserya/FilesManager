//
//  FilesServiceImpl.swift
//  DataLayer
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

class FilesServiceImpl: FilesService {

    @UserDefault(key: "files_manager_used_files", defaultValue: [])
    private var filesList: [File]

    private lazy var serviceManager = ServiceManager.shared

    func getFiles() -> AnyPublisher<[File], Error> {
        return Publishers.Sequence(sequence: [filesList]).eraseToAnyPublisher()
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
            guard let self = self else { return }

            if let error = error {
                publisher.send(completion: Subscribers.Completion<Error>.failure(error))

            } else {
                self.filesList.append(contentsOf: files)
                publisher.send(())
            }
        }

        return publisher.eraseToAnyPublisher()
    }

    func remove(files: [File], progress: ProgressIndicator?) -> AnyPublisher<Void, Error> {
        var deletedFilesCount: Double = 0
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
        }

        return publisher.eraseToAnyPublisher()
    }

}
