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

struct State {
    let actionIdentifier: String
}

struct IdentifiedAction: Action {
    let identifier: String
}

class StoreSpec: QuickSpec {
    override func spec() {
        it("publishes the initial state") {
            let store = Store<State>(reducer: { state, action in State(actionIdentifier: (action as! IdentifiedAction).identifier) },
                                     initialState: State(actionIdentifier: "initial"))
            
            var stateReceived: State?
            _ = store.subscribe { newState in
                stateReceived = newState
            }
            expect(stateReceived?.actionIdentifier).toEventually(equal("initial"))
        }
        
        it("publishes dispatched changes") {
            let store = Store<State>(reducer: { state, action in State(actionIdentifier: (action as! IdentifiedAction).identifier) },
                                     initialState: State(actionIdentifier: "initial"))
            
            var stateReceived: State?
            _ = store.subscribe { newState in
                stateReceived = newState
            }
            store.dispatch(IdentifiedAction(identifier: "dispatched"))
            expect(stateReceived?.actionIdentifier).toEventually(equal("dispatched"))
        }
        
        it("removes subscriptions when requested") {
            let store = Store<State>(reducer: { state, action in State(actionIdentifier: (action as! IdentifiedAction).identifier) },
                                     initialState: State(actionIdentifier: "initial"))
            
            var stateReceived: State?
            let unsubscribe = store.subscribe { newState in
                stateReceived = newState
            }
            unsubscribe()
            store.dispatch(IdentifiedAction(identifier: "dispatched"))
            expect(stateReceived?.actionIdentifier).toEventually(equal("initial"))
        }
    }
}