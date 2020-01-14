//
//  Publishers+Fail.swift
//  DataLayer
//
//  Created by Maria Holubieva on 14.01.2020.
//  Copyright © 2020 Maria Holubieva. All rights reserved.
//

import Combine

extension Publishers {
    struct Fail<Output, Failure>: Publisher where Failure: Error {

        private let failure: Failure

        init(outputType: Output.Type, failure: Failure) {
            self.failure = failure
        }

        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            subscriber.receive(subscription: Subscriptions.empty)
            subscriber.receive(completion: .failure(failure))
        }
    }
}
