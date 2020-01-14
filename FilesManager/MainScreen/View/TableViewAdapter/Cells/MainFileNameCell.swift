//
//  MainFileNameCell.swift
//  FilesManager
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Cocoa

class MainFileNameCell: NSTableCellView {

    @IBOutlet weak var labelFileName: NSTextField!
    @IBOutlet weak var imgFileIcon: NSImageView!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

    }
    
}
