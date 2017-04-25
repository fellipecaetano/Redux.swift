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
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    dispatch(IncrementAction(amount: 3))
                }
            }
        }

        expect(stateReceived?.counter).toEventually(equal(3))
    }

    func testMiddlewareExecution() {
        var actionDispatched: IdentifiedAction?

        let middleware: Middleware<IdentificationState> = { getState, action in
            actionDispatched = action as? IdentifiedAction
        }

        let store = IdentificationStore(middleware: [middleware])

        expect(actionDispatched).to(beNil())
        store.dispatch(IdentifiedAction(identifier: "dispatched"))
        expect(actionDispatched?.identifier) == "dispatched"
    }

    func testCommand() {
        let command = MultipleIncrementsCommand(amount: 10, times: 3)
        let store = CounterStore()

        var commandExecuted: Bool = false
        store.dispatch(command) { 
            commandExecuted = true
        }

        expect(store.actionHistory.count).toEventually(equal(3))
        expect(store.state.counter).toEventually(equal(30))
        expect(commandExecuted).toEventually(equal(true))
    }
}
