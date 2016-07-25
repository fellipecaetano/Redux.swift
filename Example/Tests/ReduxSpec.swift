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

class CounterSubscriber: Subscriber, StateConnectable {
    var counter: Int
    var connection: StateConnection?
    
    init (counter: Int) {
        self.counter = counter
    }
    
    func select(publishing: CounterState) -> Int {
        return publishing.counter
    }

    func receive(selection: Int) {
        self.counter = selection
    }
    
    func connect(with connection: StateConnection) {
        self.connection = connection
    }
}

class ReduxSpec: QuickSpec {
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
        
        it("dispatches async actions") {
            let store = Store<CounterState>(reducer: { state, action in
                return CounterState(counter: state!.counter + (action as! CounterIncrementAction).increment)
            }, initialState: CounterState(counter: 0))
            
            var stateReceived: CounterState?
            _ = store.subscribe { newState in
                stateReceived = newState
            }
            
            store.dispatch { dispatch in
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    dispatch_async(dispatch_get_main_queue()) {
                        dispatch(CounterIncrementAction(increment: 3))
                    }
                }
            }

            expect(stateReceived?.counter).toEventually(equal(3))
        }
        
        it("is compatible with Subscribers") {
            let store = Store<CounterState>(reducer: { state, action in
                return CounterState(counter: state!.counter + (action as! CounterIncrementAction).increment)
            }, initialState: CounterState(counter: 0))
            
            let subscriber = CounterSubscriber(counter: -1)
            let unsubscribe = store.subscribe(subscriber: subscriber)
            
            expect(subscriber.counter).toEventually(equal(0))
            store.dispatch(CounterIncrementAction(increment: 2))
            expect(subscriber.counter).toEventually(equal(2))
            
            unsubscribe()
            
            store.dispatch(CounterIncrementAction(increment: 3))
            expect(subscriber.counter).toEventually(equal(2))
        }
        
        it("connnects to StateConnectables") {
            let store = Store<CounterState>(reducer: { state, action in
                return CounterState(counter: state!.counter + (action as! CounterIncrementAction).increment)
            }, initialState: CounterState(counter: 0))
            
            let subscriber = CounterSubscriber(counter: -1)
            subscriber.connect(to: store)
            
            expect(subscriber.connection).toEventuallyNot(beNil())
            
            subscriber.connection?.dispatch(CounterIncrementAction(increment: 3))
            expect(subscriber.counter).toEventually(equal(3))
            
            subscriber.connection?.unsubscribe()
            subscriber.connection?.dispatch(CounterIncrementAction(increment: 3))
            expect(subscriber.counter).toEventually(equal(3))
        }
    }
}