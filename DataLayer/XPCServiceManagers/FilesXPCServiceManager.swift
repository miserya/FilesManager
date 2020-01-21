//
//  FilesXPCServiceManager.swift
//  DataLayer
//
//  Created by Maria Holubieva on 16.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import XPCSupport

protocol FilesXPCServiceManager {

    static var shared: FilesXPCServiceManager { get set }

    var errorHandler: ((Error) -> Void)? { get set }
    
    var updateProgress: ((Double) -> Void)? { get set }

    func getAttributesForFiles(at pathes: [String], completion: @escaping ([File], Error?) -> Void)

    func calculateHashForFiles(_ files: [File], completion: @escaping ([File], Error?) -> Void)

    func duplicateFiles(at pathes: [String], completion: @escaping ([String], Error?) -> Void)
}
