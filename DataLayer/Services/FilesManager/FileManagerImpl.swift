//
//  FileManagerImpl.swift
//  DataLayer
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

class FileManagerImpl: FileManager {

    func addNewFiles() -> AnyPublisher<[File], Error> {
        return Publishers.Fail(outputType: [File].self, failure: DataLayerError.notImplemented).eraseToAnyPublisher()
    }

    func remove(files: [File]) -> AnyPublisher<[File], Error> {
        return Publishers.Fail(outputType: [File].self, failure: DataLayerError.notImplemented).eraseToAnyPublisher()
    }

    func duplicate(files: [File]) -> AnyPublisher<[File], Error> {
        return Publishers.Fail(outputType: [File].self, failure: DataLayerError.notImplemented).eraseToAnyPublisher()
    }

    func calculateHashFunction(for files: [File]) -> AnyPublisher<[File], Error> {
        return Publishers.Fail(outputType: [File].self, failure: DataLayerError.notImplemented).eraseToAnyPublisher()
    }

}
