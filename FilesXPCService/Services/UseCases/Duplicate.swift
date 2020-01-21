//
//  Duplicate.swift
//  FilesXPCService
//
//  Created by Maria Holubieva on 20.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation

class Duplicate: UseCase<String, String> {

    private let filesService: FilesService = FilesServiceImpl()

    override func build(with args: String) -> Result<String, Error> {
        return filesService.duplicateFile(at: args)
    }
}
