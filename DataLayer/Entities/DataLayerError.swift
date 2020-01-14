//
//  DataLayerError.swift
//  DataLayer
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation

public enum DataLayerError: Error {
    case notImplemented
}

extension DataLayerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "This method isn't implemented"
        }
    }
}
