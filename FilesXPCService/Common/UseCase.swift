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

    func build(with args: Input) -> CurrentValueSubject<Output, Error> {
        preconditionFailure("Must be overridden!")
    }

    public func execute(with args: Input) -> CurrentValueSubject<Output, Error> {
        return build(with: args)
//            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
//            .receive(on: DispatchQueue.global(qos: .userInitiated))
//            .eraseToAnyPublisher()
    }
}

open class UseCase2<Input, Output> {

    let concurrentQueue = DispatchQueue.global()//(label: "com.miserya.Concurrent", attributes: .concurrent)

    public init() {
    }

    func build(with args: Input) -> Result<Output, Error> {
        preconditionFailure("Must be overridden!")
    }

    public func execute(with args: Input, dispatchGroup: DispatchGroup, completion: @escaping ((Result<Output, Error>) -> Void)) {
        dispatchGroup.enter()
        concurrentQueue.async { [weak self] in
            guard let self = self else { dispatchGroup.leave(); return }
            let result = self.build(with: args)
            completion(result)
            dispatchGroup.leave()
        }
        //            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        //            .receive(on: DispatchQueue.global(qos: .userInitiated))
        //            .eraseToAnyPublisher()
    }
}
