//
//  UseCase.swift
//  DataLayer
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

open class UseCase<Input, Output> {

    public init() {
    }

    func build(with args: Input) -> AnyPublisher<Output, Error> {
        preconditionFailure("Must be overridden!")
    }

    public func execute(with args: Input) -> AnyPublisher<Output, Error> {
        build(with: args)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
