//
//  AddNewFiles.swift
//  DataLayer
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

final public class AddFiles: UseCase<[URL], Void> {

    private let service: FilesService = FilesServiceImpl()

    override func build(with args: [URL], progress: ProgressIndicator?) -> AnyPublisher<Void, Error> {
        return service.add(filesAt: args, progress: progress)
    }
}
