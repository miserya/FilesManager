//
//  RemoveFiles.swift
//  DataLayer
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

final public class RemoveFiles: UseCase<[File], Void> {

    private let service: FilesService = FilesServiceImpl(serviceManager: FilesXPCServiceManagerImpl.shared, cache: FilesServiceCacheImpl())

    override func build(with args: [File], progress: ProgressIndicator?) -> AnyPublisher<Void, Error> {
        return service.remove(files: args, progress: progress)
    }
}
