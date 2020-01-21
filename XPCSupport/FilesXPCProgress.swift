//
//  FilesXPCProgress.swift
//  XPCSupport
//
//  Created by Maria Holubieva on 21.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation

@objc public protocol FilesXPCProgress {

    func updateProgress(_ currentProgress: Double)

    func finished()
}
