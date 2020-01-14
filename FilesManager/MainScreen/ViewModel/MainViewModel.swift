//
//  MainViewModel.swift
//  FilesManager
//
//  Created by Maria Holubieva on 13.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

protocol MainViewModel: AnyObject {

    var filesViewItems: CurrentValueSubject<[FileViewItem], Never> { get }

    var selectedFilesIndexes: [Int] { get set }

    func getFiles()

    func onNeedAddFiles()

    func onNeedDeleteSelectedFiles()

    func onNeedDuplicateSelectedFiles()

    func onNeedCalculateHashForSelectedFiles()
}
