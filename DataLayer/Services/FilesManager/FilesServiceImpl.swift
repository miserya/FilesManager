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

        serviceManager.getAttributesForFiles(at: urls.map({ $0.path })) { [weak self] (attributesList: [NSDictionary]) in
            guard let self = self else { return }

            var newFilesList = [File]()
            for i in 0..<attributesList.count {
                if !self.filesList.contains(where: { $0.location == urls[i] }) {
                    newFilesList.append(File(name: urls[i].lastPathComponent, size: attributesList[i].fileSize(), location: urls[i]))
                }
            }
            self.filesList.append(contentsOf: newFilesList)
            publisher.send(())
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
        serviceManager.duplicateFiles(at: files.map({ $0.location.path })) { (newPathes: [String]) in
            publisher.send(newPathes)
        }
        return publisher.eraseToAnyPublisher()
    }

    func calculateHash(for files: [File]) -> AnyPublisher<[String], Error> {
        let publisher = PassthroughSubject<[String], Error>()
        serviceManager.errorHandler = { (error) in
            publisher.send(completion: Subscribers.Completion<Error>.failure(error))
        }
        serviceManager.calculateHashForFiles(at: files.map({ $0.location.path })) { (hashes: [String]) in
            publisher.send(hashes)
        }
        return publisher.eraseToAnyPublisher()
    }

}
