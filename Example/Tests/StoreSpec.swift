//
//  StoreSpec.swift
//  Redux.swift
//
//  Created by Fellipe Caetano on 7/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Redux_swift

struct ActionIdentificationState {
    let actionIdentifier: String
}

struct IdentifiedAction: Action {
    let identifier: String
}

struct CounterState {
    let counter: Int
}

struct CounterIncrementAction: Action {
    let increment: Int
}

class StoreSpec: QuickSpec {
    override func spec() {
        it("publishes the initial state") {
            let store = Store<ActionIdentificationState>(reducer: { state, action in
                return ActionIdentificationState(actionIdentifier: (action as! IdentifiedAction).identifier)
            }, initialState: ActionIdentificationState(actionIdentifier: "initial"))
            
            var stateReceived: ActionIdentificationState?
            _ = store.subscribe { newState in
                stateReceived = newState
            }
            expect(stateReceived?.actionIdentifier).toEventually(equal("initial"))
        }
        
        it("publishes dispatched changes") {
            let store = Store<ActionIdentificationState>(reducer: { state, action in
                return ActionIdentificationState(actionIdentifier: (action as! IdentifiedAction).identifier)
            }, initialState: ActionIdentificationState(actionIdentifier: "initial"))
            
            var stateReceived: ActionIdentificationState?
            _ = store.subscribe { newState in
                stateReceived = newState
            }
            store.dispatch(IdentifiedAction(identifier: "dispatched"))
            expect(stateReceived?.actionIdentifier).toEventually(equal("dispatched"))
        }
        
        it("removes subscriptions when requested") {
            let store = Store<ActionIdentificationState>(reducer: { state, action in
                return ActionIdentificationState(actionIdentifier: (action as! IdentifiedAction).identifier)
            }, initialState: ActionIdentificationState(actionIdentifier: "initial"))
            
            var stateReceived: ActionIdentificationState?
            let unsubscribe = store.subscribe { newState in
                stateReceived = newState
            }
            unsubscribe()
            store.dispatch(IdentifiedAction(identifier: "dispatched"))
            expect(stateReceived?.actionIdentifier).toEventually(equal("initial"))
        }
        
        it("reduces actions and state into new state") {
            let store = Store<CounterState>(reducer: { state, action in
                return CounterState(counter: state!.counter + (action as! CounterIncrementAction).increment)
            }, initialState: CounterState(counter: 0))
            
            var stateReceived: CounterState?
            _ = store.subscribe { newState in
                stateReceived = newState
            }
            
            expect(stateReceived?.counter).toEventually(equal(0))
            store.dispatch(CounterIncrementAction(increment: 5))
            expect(stateReceived?.counter).toEventually(equal(5))
            store.dispatch(CounterIncrementAction(increment: -2))
            expect(stateReceived?.counter).toEventually(equal(3))
        }
    }
}