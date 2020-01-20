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

    func add(filesAt urls: [URL]) -> AnyPublisher<Void, Error> {
        let publisher = PassthroughSubject<Void, Error>()

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

    func remove(files: [File]) -> AnyPublisher<Void, Error> {
        filesList.removeAll { (file: File) -> Bool in
            files.contains(where: { $0.location == file.location })
        }
        return Publishers.Sequence(sequence: [()]).eraseToAnyPublisher()
    }

    func duplicate(files: [File]) -> AnyPublisher<[String], Error> {
        let publisher = PassthroughSubject<[String], Error>()

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

    func calculateHash(for files: [File], progress: Progress) -> AnyPublisher<[File], Error> {
        progress.totalUnitCount = Int64(files.count)
        progress.completedUnitCount = 0
        progress.becomeCurrent(withPendingUnitCount: Int64(files.count))

        var publishers = [PassthroughSubject<File, Error>]()
        for file in files {
            let publisher = PassthroughSubject<File, Error>()
            publishers.append(publisher)
            serviceManager.errorHandler = { (error) in
                publisher.send(completion: Subscribers.Completion<Error>.failure(error))
            }
            serviceManager.calculateHashForFile(file) { (file: File?, error: Error?) in
                if let error = error {
                    publisher.send(completion: Subscribers.Completion<Error>.failure(error))

                } else if let file = file {
                    publisher.send(file)

                } else {
                    publisher.send(completion: Subscribers.Completion<Error>.failure(DataLayerError.unknown))
                }
                publisher.send(completion: .finished)
                progress.completedUnitCount += 1
            }
        }

        return Publishers.MergeMany(publishers).collect().eraseToAnyPublisher()
    }

}
