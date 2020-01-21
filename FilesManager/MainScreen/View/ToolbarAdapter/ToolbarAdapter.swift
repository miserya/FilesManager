//
//  ToolbarAdapter.swift
//  FilesManager
//
//  Created by Maria Holubieva on 21.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import Cocoa

class ToolbarAdapter {

    private enum Item: String {
        case add = "Add"
        case duplicate = "Duplicate"
        case hash = "Hash"
        case remove = "Remove"
    }

    var isFilesActionsEnabled: Bool = false

    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        switch item.itemIdentifier.rawValue {

        case Item.duplicate.rawValue, Item.hash.rawValue, Item.remove.rawValue:
            return isFilesActionsEnabled
        case Item.add.rawValue:
            return true
        default:
            return false
        }
    }
}
