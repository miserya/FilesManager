//
//  MainViewControllerImpl.swift
//  FilesManager
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Cocoa
import Combine

class MainViewControllerImpl: NSViewController, MainViewController, NSToolbarItemValidation {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    private var subscriptions = [AnyCancellable]()

    private lazy var viewModel: MainViewModel = MainViewModelImpl()
    private lazy var adapter = MainTableViewAdapter()
    private lazy var toolbarAdapter = ToolbarAdapter()

    override var representedObject: Any? {
        didSet {
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = adapter
        tableView.dataSource = adapter

        adapter.tableView = tableView

        setupSubscriptions()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        viewModel.getFiles()
    }

    //MARK: - Toolbar actions

    @IBAction func onAddFiles(_ sender: Any) {
        viewModel.startImportFilesAction()
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
            .sink(receiveValue: { [weak self] (newIndexes: [Int]) in
                self?.viewModel.setSelectedFilesIndexes(newIndexes) })
            .store(in: &subscriptions)

        viewModel.error
            .sink { [weak self] (error: Error?) in
                guard let error = error, let self = self else { return }
                self.show(error: error) }
            .store(in: &subscriptions)

        viewModel.isFilesActionsEnabled
            .sink(receiveCompletion: { _ in }) { (value: Bool) in
                if let appDel = NSApplication.shared.delegate as? AppDelegate {
                    appDel.enableActions(duplicate: value, calculateHash: value, delete: value)
                } }
            .store(in: &subscriptions)

        viewModel.isFilesActionsEnabled
            .assign(to: \.isFilesActionsEnabled, on: toolbarAdapter)
            .store(in: &subscriptions)

        viewModel.isOpenPanelShowed
            .sink(receiveCompletion: { _ in }) { [weak self] (value: Bool) in
                if value {
                    self?.showOpenPanel()
                } }
            .store(in: &subscriptions)

        viewModel.isLoading
            .sink(receiveValue: { [weak self] (value: Bool) in
                if value {
                    self?.progressIndicator.isHidden = false
                } else {
                    self?.progressIndicator.isHidden = true
                }
            })
            .store(in: &subscriptions)

        viewModel.progressMaxValue
            .assign(to: \.maxValue, on: progressIndicator)
            .store(in: &subscriptions)

        viewModel.progressValue
            .receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] (value: Double) in
                guard let self = self else { return }
                self.progressIndicator.increment(by: value - self.progressIndicator.doubleValue)
            })
            .store(in: &subscriptions)
    }

    private func showOpenPanel() {
        guard let window = view.window else { return }

        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true

        panel.beginSheetModal(for: window) { [unowned panel, unowned viewModel] (result) in
            if result == NSApplication.ModalResponse.OK {
                viewModel.endImportFilesAction()
                viewModel.addFiles(at: panel.urls)
            }
        }
    }

    //MARK: - NSToolbarItemValidation

    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        return toolbarAdapter.validateToolbarItem(item)
    }
}
