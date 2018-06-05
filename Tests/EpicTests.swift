import XCTest
import Nimble
import Redux
import RxSwift

class EpicTests: XCTestCase {
    func testActionTransformation() {
        let epic: Epic<CounterState> = { _, actions in
            actions.flatMap({ action -> Observable<Action> in
                if let action = action as? IncrementAction {
                    return .just(DecrementAction(amount: action.amount * 3))
                } else {
                    return .empty()
                }
            })
        }

        let store = CounterStore(middleware: Epics.middleware(epic))

        var stateReceived: CounterState?
        _ = store.subscribe { newState in
            stateReceived = newState
        }

        store.dispatch(IncrementAction(amount: 5))
        expect(stateReceived?.counter).toEventually(equal(-10))
    }

    func testMiddlewareChain() {
        let epic: Epic<CounterState> = { _, actions in
            actions.flatMap({ action -> Observable<Action> in
                if let action = action as? IncrementAction {
                    return .just(DecrementAction(amount: action.amount * 6))
                } else {
                    return .empty()
                }
            })
        }

        var actionReceivedByMiddleware: Action?

        let middleware: Middleware<CounterState> = { _ in { next in { action in
            actionReceivedByMiddleware = action

            if let action = action as? DecrementAction {
                next(DecrementAction(amount: Int(action.amount / 2)))
            } else {
                next(action)
            }
        }}}

        let store = CounterStore(middleware: Epics.middleware(epic), middleware)

        var stateReceived: CounterState?
        _ = store.subscribe { newState in
            stateReceived = newState
        }

        store.dispatch(IncrementAction(amount: 1))
        expect(actionReceivedByMiddleware as? DecrementAction).toEventually(equal(DecrementAction(amount: 6)))
        expect(stateReceived?.counter).toEventually(equal(-2))
    }
}
