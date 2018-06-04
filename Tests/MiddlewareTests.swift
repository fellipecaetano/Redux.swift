import XCTest
import Nimble
import Redux

class MiddlewareTests: XCTestCase {
    func testMiddlewareActionChaining() {
        let middleware: Middleware<IdentificationState> = { _,_  in { next in { action in next(action) }}}
        let store = IdentificationStore(middleware: middleware)

        var stateReceived: IdentificationState?
        _ = store.subscribe { newState in
            stateReceived = newState
        }

        store.dispatch(IdentifiedAction(identifier: "dispatched"))
        expect(stateReceived?.identifier).toEventually(equal("dispatched"))
    }

    func testMiddlewareActionCancellation() {
        let middleware: Middleware<IdentificationState> = { _,_  in { next in { action in
            if let action = action as? IdentifiedAction, action.identifier == "cancel" {
                return
            }

            next(action)
        }}}

        let store = IdentificationStore(middleware: middleware)

        var stateReceived: IdentificationState?
        _ = store.subscribe { newState in
            stateReceived = newState
        }

        store.dispatch(IdentifiedAction(identifier: "dispatched"))
        store.dispatch(IdentifiedAction(identifier: "cancel"))
        expect(stateReceived?.identifier).toEventually(equal("dispatched"))
    }

    func testMiddlewareStateAccessor() {
        var stateReceived: IdentificationState?

        let middleware: Middleware<IdentificationState> = { getState, _ in { next in { action in
            next(action)
            stateReceived = getState()
        }}}

        let store = IdentificationStore(middleware: middleware)
        store.dispatch(IdentifiedAction(identifier: "dispatched"))
        expect(stateReceived?.identifier).toEventually(equal("dispatched"))
    }
}
