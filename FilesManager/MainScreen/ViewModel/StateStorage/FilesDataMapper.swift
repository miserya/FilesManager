//
//  FilesDataMapper.swift
//  FilesManager
//
//  Created by Maria Holubieva on 21.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import DataLayer
import Cocoa

class FilesDataMapper {

    func map(_ files: [File]) -> [FileViewItem] {
        return files.map({ self.map($0) })
    }

    func map(_ file: File) -> FileViewItem {
        return FileViewItem(image: NSWorkspace.shared.icon(forFile: file.location.path),
                            name: file.name,
                            size: ByteCountFormatter().string(fromByteCount: Int64(file.size)),
                            hash: file.hash,
                            location: file.location.path)
    }
}
