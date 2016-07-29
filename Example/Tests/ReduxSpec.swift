import Foundation
import Quick
import Nimble
import Redux

class ReduxSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        it("publishes the initial state") {
            let store = IdentificationStore()

            var stateReceived: IdentificationState?
            _ = store.subscribe { newState in
                stateReceived = newState
            }

            expect(stateReceived?.identifier).toEventually(equal("initial"))
        }

        it("publishes dispatched changes") {
            let store = IdentificationStore()

            var stateReceived: IdentificationState?
            _ = store.subscribe { newState in
                stateReceived = newState
            }

            store.dispatch(IdentifiedAction(identifier: "dispatched"))
            expect(stateReceived?.identifier).toEventually(equal("dispatched"))
        }

        it("removes subscriptions when requested") {
            let store = IdentificationStore()

            var stateReceived: IdentificationState?
            let unsubscribe = store.subscribe { newState in
                stateReceived = newState
            }
            unsubscribe()

            store.dispatch(IdentifiedAction(identifier: "dispatched"))
            expect(stateReceived?.identifier).toEventually(equal("initial"))
        }

        it("reduces actions and state into new state") {
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

        it("dispatches async actions") {
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

        it("is compatible with Subscribers") {
            let store = CounterStore()

            let subscriber = CounterSubscriber(counter: -1)
            let unsubscribe = store.subscribe(subscriber: subscriber)

            expect(subscriber.counter).toEventually(equal(0))

            store.dispatch(IncrementAction(amount: 2))
            expect(subscriber.counter).toEventually(equal(2))

            unsubscribe()
            store.dispatch(IncrementAction(amount: 3))
            expect(subscriber.counter).toEventually(equal(2))
        }

        it("connnects to StateConnectables") {
            let store = CounterStore()

            let subscriber = CounterSubscriber(counter: -1)
            subscriber.connect(to: store)
            subscriber.connection?.subscribe()

            expect(subscriber.connection).toEventuallyNot(beNil())

            subscriber.connection?.dispatch(IncrementAction(amount: 3))
            expect(subscriber.counter).toEventually(equal(3))

            subscriber.connection?.unsubscribe()
            subscriber.connection?.dispatch(IncrementAction(amount: 3))
            expect(subscriber.counter).toEventually(equal(3))
        }
    }
}
