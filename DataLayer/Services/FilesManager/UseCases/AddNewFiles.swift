//
//  AddNewFiles.swift
//  DataLayer
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

final public class AddNewFiles: UseCase<Void, [File]> {

    private let service: FileManager = FileManagerImpl()

    override func build(with args: Void) -> AnyPublisher<[File], Error> {
        return service.addNewFiles()
    }
}
