//
//  MainTableViewAdapter.swift
//  FilesManager
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Cocoa
import Combine

class MainTableViewAdapter: NSObject, NSTableViewDelegate, NSTableViewDataSource {

    private enum Column: String {
        case name = "FileName"
        case size = "FileSize"
        case hash = "FileHash"
        case location = "FileLocation"

        var itemID: NSUserInterfaceItemIdentifier {
            return NSUserInterfaceItemIdentifier(self.rawValue)
        }
    }

    var files = [FileViewItem]()
    @Published private(set) var selectedFilesIndexes = [Int]()

    func numberOfRows(in tableView: NSTableView) -> Int {
        return files.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = files[row]

        switch tableColumn?.identifier {
        case Column.name.itemID?:
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MainFileNameCell"), owner: nil) as? MainFileNameCell
            cell?.labelFileName.stringValue = item.name
            return cell

        case Column.size.itemID?:
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MainFileInfoCell"), owner: nil) as? MainFileInfoCell
            cell?.labelInfo.stringValue = item.size
            return cell

        case Column.hash.itemID?:
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MainFileInfoCell"), owner: nil) as? MainFileInfoCell
            cell?.labelInfo.stringValue = item.hash ?? "-"
            return cell

        case Column.location.itemID?:
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("MainFileInfoCell"), owner: nil) as? MainFileInfoCell
            cell?.labelInfo.stringValue = item.location
            return cell

        case .none, .some:
            return nil
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { return }

        var indexes = [Int]()
        for (_, index) in tableView.selectedRowIndexes.enumerated() {
            indexes.append(index)
        }
        selectedFilesIndexes = indexes
    }
}
