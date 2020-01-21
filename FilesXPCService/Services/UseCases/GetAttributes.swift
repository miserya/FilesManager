//
//  GetAttributes.swift
//  FilesXPCService
//
//  Created by Maria Holubieva on 20.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import XPCSupport

class GetAttributes: UseCase<FileEntity, FileAttributes> {

    private let filesService: FilesService = FilesServiceImpl()

    override func build(with args: FileEntity) -> Result<FileAttributes, Error> {
        return filesService.getAttributesForFile(args)
    }
}

