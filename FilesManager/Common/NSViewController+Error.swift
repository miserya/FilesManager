//
//  NSViewController+Error.swift
//  FilesManager
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Cocoa

extension NSViewController {

    func show(error: Error) {
        let alert = NSAlert(error: error)
        alert.runModal()
    }
}
