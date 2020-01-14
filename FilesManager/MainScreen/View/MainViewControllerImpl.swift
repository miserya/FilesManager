//
//  MainViewControllerImpl.swift
//  FilesManager
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Cocoa
import Combine

class MainViewControllerImpl: NSViewController, MainViewController {

    @IBOutlet weak var tableView: NSTableView!

    private var subscriptions = [AnyCancellable]()

    private lazy var viewModel: MainViewModel = MainViewModelImpl()
    private lazy var adapter = MainTableViewAdapter()

    override var representedObject: Any? {
        didSet {
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = adapter
        tableView.dataSource = adapter

        setupSubscriptions()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        viewModel.getFiles()
        tableView.reloadData()
    }

    //MARK: - Toolbar actions

    @IBAction func onAddFiles(_ sender: Any) {
        viewModel.onNeedAddFiles()
    }

    @IBAction func onDeleteFiles(_ sender: Any) {
        viewModel.onNeedDeleteSelectedFiles()
    }

    @IBAction func onDuplicateFiles(_ sender: Any) {
        viewModel.onNeedDuplicateSelectedFiles()
    }

    @IBAction func onCalculateHash(_ sender: Any) {
        viewModel.onNeedCalculateHashForSelectedFiles()
    }

    //MARK: - Private

    private func setupSubscriptions() {
        viewModel.filesViewItems
            .assign(to: \.files, on: adapter)
            .store(in: &subscriptions)

        adapter.$selectedFilesIndexes
            .assign(to: \.selectedFilesIndexes, on: viewModel)
            .store(in: &subscriptions)

        viewModel.error
            .sink { [weak self] (error: Error?) in
                guard let error = error, let self = self else { return }
                self.show(error: error) }
            .store(in: &subscriptions)
    }
}
