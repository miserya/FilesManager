//
//  CalculateHash.swift
//  DataLayer
//
//  Created by Maria Holubieva on 16.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

final public class CalculateHash: UseCase<[File], [File]> {

    private let service: FilesService = FilesServiceImpl()

    override func build(with args: [File], progress: ProgressIndicator?) -> AnyPublisher<[File], Error> {
        return service.calculateHash(for: args, progress: progress)
    }
}
