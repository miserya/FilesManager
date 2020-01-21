//
//  ProgressIndicator.swift
//  DataLayer
//
//  Created by Maria Holubieva on 21.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import Combine

public class ProgressIndicator {
    @Published public var currentProgress: Double

    public init() {
        currentProgress = 0
    }

    public func reset() {
        currentProgress = 0
    }
}
