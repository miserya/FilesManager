//
//  FilesService.swift
//  FilesXPCService
//
//  Created by Maria Holubieva on 20.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import XPCSupport

protocol FilesService {

    func getAttributesForFile(_ file: FileEntity) -> Result<FileAttributes, Error>

    func duplicateFile(at path: String) -> Result<String, Error>

    func calculateHashForFile(_ file: FileEntity) -> Result<FileHash, Error>
}
