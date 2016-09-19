import XCTest
import Nimble
import Redux

class ReduxTests: XCTestCase {
    func testInitialState() {
        let store = IdentificationStore()

        var stateReceived: IdentificationState?
        _ = store.subscribe { newState in
            stateReceived = newState
        }

        expect(stateReceived?.identifier).toEventually(equal("initial"))
    }

    func testDispatchedChanges() {
        let store = IdentificationStore()

        var stateReceived: IdentificationState?
        _ = store.subscribe { newState in
            stateReceived = newState
        }

        store.dispatch(IdentifiedAction(identifier: "dispatched"))
        expect(stateReceived?.identifier).toEventually(equal("dispatched"))
    }

    func testSubscriptionDisposal() {
        let store = IdentificationStore()

        var stateReceived: IdentificationState?
        let unsubscribe = store.subscribe { newState in
            stateReceived = newState
        }
        unsubscribe()

        store.dispatch(IdentifiedAction(identifier: "dispatched"))
        expect(stateReceived?.identifier).toEventually(equal("initial"))
    }

    func testReduction() {
        let store = CounterStore()

        var stateReceived: CounterState?
        _ = store.subscribe { newState in
            stateReceived = newState
        }

        expect(stateReceived?.counter).toEventually(equal(0))

        store.dispatch(IncrementAction(amount: 5))
        expect(stateReceived?.counter).toEventually(equal(5))

        store.dispatch(DecrementAction(amount: 2))
        expect(stateReceived?.counter).toEventually(equal(3))
    }

    func testAsynchronousDispatches() {
        let store = CounterStore()

        var stateReceived: CounterState?
        _ = store.subscribe { newState in
            stateReceived = newState
        }

        store.dispatch { dispatch in
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                dispatch_async(dispatch_get_main_queue()) {
                    dispatch(IncrementAction(amount: 3))
                }
            }
        }

        expect(stateReceived?.counter).toEventually(equal(3))
    }

    func testAsynchronousDispatchesWithStateReading() {
        let store = CounterStore()

        var stateReceived: CounterState?
        _ = store.subscribe { newState in
            stateReceived = newState
        }

        store.dispatch { dispatch, getState in
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                dispatch_async(dispatch_get_main_queue()) {
                    dispatch(IncrementAction(amount: getState().counter + 1)) // counter + 1
                    dispatch(IncrementAction(amount: getState().counter + 2)) // (counter + 1 + 2)
                }
            }
        }

        expect(stateReceived?.counter).toEventually(equal(4))
    }
}
