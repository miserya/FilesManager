//
//  UseCase.swift
//  FilesXPCService
//
//  Created by Maria Holubieva on 20.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Foundation
import Combine

open class UseCase<Input, Output> {

    let concurrentQueue = DispatchQueue(label: "com.miserya.Concurrent", attributes: .concurrent)

    public init() {
    }

    func build(with args: Input) -> Result<Output, Error> {
        preconditionFailure("Must be overridden!")
    }

    public func execute(with args: Input) -> AnyPublisher<Output, Error> {
        let publisher = PassthroughSubject<Output, Error>()

        DispatchQueue.global().async { [weak self] in
            let result = self?.build(with: args)

            switch result {
            case .success(let successResult)?:
                publisher.send(successResult)
                publisher.send(completion: .finished)

            case .failure(let error)?:
                publisher.send(completion: .failure(error))
                publisher.send(completion: .finished)

            default:
                publisher.send(completion: .finished)
            }
        }

        return publisher.eraseToAnyPublisher()
    }
}
