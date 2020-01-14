//
//  RemoveFiles.swift
//  DataLayer
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

final public class RemoveFiles: UseCase<[File], [File]> {

    private let service: FileManager = FileManagerImpl()

    override func build(with args: [File]) -> AnyPublisher<[File], Error> {
        return service.remove(files: args)
    }
}
