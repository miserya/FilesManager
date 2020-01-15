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

    private let fileManager = FileManager.default

    func getFiles() -> AnyPublisher<[File], Error> {
        return Publishers.Sequence(sequence: [filesList]).eraseToAnyPublisher()
    }

    func add(filesAt urls: [URL]) -> AnyPublisher<Void, Error> {
        do {
            let newFilesList = try urls.compactMap { (url: URL) -> File? in
                guard !filesList.contains(where: { $0.location == url }) else { return nil }

                let attributes = try NSDictionary(dictionary: fileManager.attributesOfItem(atPath: url.path))
                return File(name: url.lastPathComponent,
                            size: attributes.fileSize(),
                            location: url)
            }
            filesList.append(contentsOf: newFilesList)
            return Publishers.Sequence(sequence: [()]).eraseToAnyPublisher()
            
        } catch {
            return Publishers.Fail(outputType: Void.self, failure: error).eraseToAnyPublisher()
        }
    }

    func remove(files: [File]) -> AnyPublisher<Void, Error> {
        filesList.removeAll { (file: File) -> Bool in
            files.contains(where: { $0.location == file.location })
        }
        return Publishers.Sequence(sequence: [()]).eraseToAnyPublisher()
    }

    func duplicate(files: [File]) -> AnyPublisher<[File], Error> {
        return Publishers.Fail(outputType: [File].self, failure: DataLayerError.notImplemented).eraseToAnyPublisher()
    }

    func calculateHashFunction(for files: [File]) -> AnyPublisher<[File], Error> {
        return Publishers.Fail(outputType: [File].self, failure: DataLayerError.notImplemented).eraseToAnyPublisher()
    }

}
