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

    func add(filesAt urls: [URL], progress: ProgressIndicator?) -> AnyPublisher<Void, Error>

    func remove(files: [File], progress: ProgressIndicator?) -> AnyPublisher<Void, Error>

    func duplicate(files: [File], progress: ProgressIndicator?) -> AnyPublisher<[String], Error>

    func calculateHash(for files: [File], progress: ProgressIndicator?) -> AnyPublisher<[File], Error>

}


