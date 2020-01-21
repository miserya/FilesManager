//
//  MockFilesXPCSerivceManager.swift
//  DataLayerTests
//
//  Created by Maria Holubieva on 21.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
@testable import DataLayer

class MockFilesXPCServiceManager: FilesXPCServiceManager {

    var mockPathes = [String]()
    var mockFiles = [File]()
    var mockError: Error?
    var shouldThrowError: Bool = false

    //MARK: - FilesXPCServiceManager

    static var shared: FilesXPCServiceManager = MockFilesXPCServiceManager()

    var errorHandler: ((Error) -> Void)?
    var updateProgress: ((Double) -> Void)?

    func getAttributesForFiles(at pathes: [String], completion: @escaping ([File], Error?) -> Void) {
        if shouldThrowError {
            errorHandler?(TestingError.test)
        } else {
            completion(mockFiles, mockError)
        }
    }

    func calculateHashForFiles(_ files: [File], completion: @escaping ([File], Error?) -> Void) {
        if shouldThrowError {
            errorHandler?(TestingError.test)
        } else {
            completion(mockFiles, mockError)
        }
    }

    func duplicateFiles(at pathes: [String], completion: @escaping ([String], Error?) -> Void) {
        if shouldThrowError {
            errorHandler?(TestingError.test)
        } else {
            completion(mockPathes, mockError)
        }
    }

}
