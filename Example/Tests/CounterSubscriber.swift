//
//  CounterSubscriber.swift
//  Redux.swift
//
//  Created by Fellipe Caetano on 7/25/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Redux

class CounterSubscriber: StateConnectable, Subscriber {
    private(set) var connection: StateConnectionProtocol?
    private(set) var counter: Int

    init (counter: Int) {
        self.counter = counter
    }

    func connect(with connection: StateConnectionProtocol) {
        self.connection = connection
    }

    func select(state: CounterState) -> Int {
        return state.counter
    }

    func receive(counter: Int) {
        self.counter = counter
    }
}
