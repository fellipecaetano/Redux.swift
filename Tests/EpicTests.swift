import XCTest
import Nimble
import Redux
import RxSwift

class EpicTests: XCTestCase {
    func testActionTransformation() {
        let epic: Epic<CounterState> = { _, actions in
            actions.map({ action in
                if let action = action as? IncrementAction {
                    return IncrementAction(amount: action.amount * 2)
                } else {
                    return action
                }
            })
        }

        let store = CounterStore(middleware: Epics.middleware(epic))

        var stateReceived: CounterState?
        _ = store.subscribe { newState in
            stateReceived = newState
        }

        store.dispatch(IncrementAction(amount: 5))
        // The initial action passes through, and is re-dispatched after being transformed
        expect(stateReceived?.counter) == 15
    }

    func testActionFiltering() {
        let epic: Epic<CounterState> = { _, actions in
            actions.filter({ action in
                return action is DecrementAction
            })
        }

        let store = CounterStore(middleware: Epics.middleware(epic))

        var stateReceived: CounterState?
        _ = store.subscribe { newState in
            stateReceived = newState
        }

        store.dispatch(DecrementAction(amount: 3)) // Happens twice
        store.dispatch(IncrementAction(amount: 5)) // Happens once
        expect(stateReceived?.counter) == -1
    }
}
