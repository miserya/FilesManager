//
//  FilesXPCServiceError.swift
//  FilesXPCService
//
//  Created by Maria Holubieva on 17.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation

enum FilesXPCServiceError: Error {
    case invalidPathToFile(String)
    case invalidHash(String)
}

extension FilesXPCServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidPathToFile(let path):
            return "Invalid Path To File \(path)"
        case .invalidHash(let path):
            return "Can't get hash for file at path \(path)"
        }
    }
}
