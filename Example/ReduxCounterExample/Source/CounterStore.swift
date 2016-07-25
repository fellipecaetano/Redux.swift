//
//  CounterStore.swift
//  Redux.swift
//
//  Created by Fellipe Caetano on 7/25/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Redux

class CounterStore: Publisher, Dispatch {
    private let store = Store<CounterState>(initialState: CounterState()) { state, action in
        switch action {
        case let action as IncrementAction:
            return CounterState(counter: state.counter + action.amount)

        case let action as DecrementAction:
            return CounterState(counter: state.counter - action.amount)

        default:
            return state
        }
    }

    func subscribe(subscription: CounterState -> Void) -> Void -> Void {
        return store.subscribe(subscription)
    }

    func dispatch(action: Action) {
        return store.dispatch(action)
    }
}

struct CounterState {
    let counter: Int

    init (counter: Int = 0) {
        self.counter = counter
    }
}

struct IncrementAction: Action {
    let amount: Int
}

struct DecrementAction: Action {
    let amount: Int
}
