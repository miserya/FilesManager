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
    private var files: [File]

    private let fileManager = FileManager.default

    func getFiles() -> AnyPublisher<[File], Error> {
        return Publishers.Sequence(sequence: [files]).eraseToAnyPublisher()
    }

    func add(filesAt urls: [URL]) -> AnyPublisher<Void, Error> {
        do {
            let newFilesList = try urls.map { (url: URL) -> File in
                let attributes = try NSDictionary(dictionary: fileManager.attributesOfItem(atPath: url.path))
                return File(name: url.lastPathComponent,
                            size: attributes.fileSize(),
                            location: url)
            }
            files.append(contentsOf: newFilesList)
            return Publishers.Sequence(sequence: [()]).eraseToAnyPublisher()
        } catch {
            return Publishers.Fail(outputType: Void.self, failure: error).eraseToAnyPublisher()
        }
    }

    func remove(files: [File]) -> AnyPublisher<Void, Error> {
        return Publishers.Fail(outputType: Void.self, failure: DataLayerError.notImplemented).eraseToAnyPublisher()
    }

    func duplicate(files: [File]) -> AnyPublisher<[File], Error> {
        return Publishers.Fail(outputType: [File].self, failure: DataLayerError.notImplemented).eraseToAnyPublisher()
    }

    func calculateHashFunction(for files: [File]) -> AnyPublisher<[File], Error> {
        return Publishers.Fail(outputType: [File].self, failure: DataLayerError.notImplemented).eraseToAnyPublisher()
    }

}
