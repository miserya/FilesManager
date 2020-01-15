//
//  FilesService.swift
//  DataLayer
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

protocol FilesService {

    func getFiles() -> AnyPublisher<[File], Error>

    func add(filesAt urls: [URL]) -> AnyPublisher<Void, Error>

    func remove(files: [File]) -> AnyPublisher<Void, Error>

    func duplicate(files: [File]) -> AnyPublisher<[File], Error>

    func calculateHashFunction(for files: [File]) -> AnyPublisher<[File], Error>
    
}


