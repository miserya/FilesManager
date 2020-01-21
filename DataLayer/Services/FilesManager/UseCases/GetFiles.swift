//
//  GetFiles.swift
//  DataLayer
//
//  Created by Maria Holubieva on 15.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

final public class GetFiles: UseCase<Void, [File]> {

    private let service: FilesService = FilesServiceImpl(serviceManager: FilesXPCServiceManagerImpl.shared, cache: FilesServiceCacheImpl())

    override func build(with args: Void, progress: ProgressIndicator?) -> AnyPublisher<[File], Error> {
        return service.getFiles()
    }
}
