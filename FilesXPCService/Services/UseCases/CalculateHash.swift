//
//  CalculateHash.swift
//  FilesXPCService
//
//  Created by Maria Holubieva on 20.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import XPCSupport

class CalculateHash {//: UseCase2<FileEntity, FileHash> {

    private let filesService: FilesService = FilesServiceImpl()

    func build(with args: FileEntity) -> Result<FileHash, Error> {
        return filesService.calculateHashForFile(args)
    }
}
