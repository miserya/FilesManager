//
//  MainViewModel.swift
//  FilesManager
//
//  Created by Maria Holubieva on 13.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import Combine

protocol MainViewModel: AnyObject {

    var filesViewItems: CurrentValueSubject<[FileViewItem], Never> { get }

    var selectedFilesIndexes: [Int] { get set }

    var error: PassthroughSubject<Error?, Never> { get set }

    var isFilesActionsEnabled: CurrentValueSubject<Bool, Never> { get }

    var isOpenPanelShowed: CurrentValueSubject<Bool, Never> { get }

    var isLoading: CurrentValueSubject<Bool, Never> { get }

    var progressMaxValue: CurrentValueSubject<Double, Never> { get }

    var progressValue: CurrentValueSubject<Double, Never> { get }

    func getFiles()

    func startImportFilesAction()

    func endImportFilesAction()

    func addFiles(at urls: [URL])

    func onNeedDeleteSelectedFiles()

    func onNeedDuplicateSelectedFiles()

    func onNeedCalculateHashForSelectedFiles()

}
