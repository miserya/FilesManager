//
//  DuplicateFiles.swift
//  DataLayer
//
//  Created by Maria Holubieva on 17.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

final public class DuplicateFiles: UseCase<[File], [String]> {

    private let service: FilesService = FilesServiceImpl()

    override func build(with args: [File]) -> AnyPublisher<[String], Error> {
        return service.duplicate(files: args)
    }
}
