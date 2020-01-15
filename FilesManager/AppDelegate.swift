//
//  AppDelegate.swift
//  FilesManager
//
//  Created by Maria Holubieva on 13.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var btnAdd: NSMenuItem!
    @IBOutlet weak var btnDuplicate: NSMenuItem!
    @IBOutlet weak var btnCalculateHash: NSMenuItem!
    @IBOutlet weak var btnDelete: NSMenuItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        enableActions(duplicate: false, calculateHash: false, delete: false)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func enableActions(duplicate: Bool, calculateHash: Bool, delete: Bool) {
        btnDuplicate.isEnabled = duplicate
        btnCalculateHash.isEnabled = calculateHash
        btnDelete.isEnabled = delete
    }

}

