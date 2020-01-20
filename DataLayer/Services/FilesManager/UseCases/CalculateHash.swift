//
//  CalculateHash.swift
//  DataLayer
//
//  Created by Maria Holubieva on 16.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

final public class CalculateHash: UseCase<([File], Progress), [File]> {

    private let service: FilesService = FilesServiceImpl()

    override func build(with args: ([File], Progress)) -> AnyPublisher<[File], Error> {
        return service.calculateHash(for: args.0, progress: args.1)
    }
}
