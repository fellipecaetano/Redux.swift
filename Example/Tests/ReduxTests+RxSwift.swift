import XCTest
import Redux
import RxSwift
import Nimble

class ReduxRxSwiftTests: XCTestCase {
    private let disposeBag = DisposeBag()

    func testInitialObservation() {
        let observable = IdentificationStore().asObservable()
        var stateReceived: IdentificationState?

        observable.subscribeNext { state in
            stateReceived = state
        }.addDisposableTo(disposeBag)

        expect(stateReceived?.identifier).toEventually(equal("initial"))
    }

    func testDispatchObservations() {
        let store = IdentificationStore()
        var stateReceived: IdentificationState?

        store.asObservable().subscribeNext { state in
            stateReceived = state
        }.addDisposableTo(disposeBag)

        let action = IdentifiedAction(identifier: "observe_this")
        store.dispatch(action)
        expect(stateReceived?.identifier).toEventually(equal(action.identifier))
    }

    func testObservableDisposal() {
        let store = DisposalSpyStore()
        var stateReceived: IdentificationState?

        let disposable = store.asObservable().subscribeNext { state in
            stateReceived = state
        }
        disposable.dispose()

        expect(store.didUnsubscribe).toEventually(beTrue())

        let action = IdentifiedAction(identifier: "observe_this")
        store.dispatch(action)
        expect(stateReceived?.identifier).toEventually(equal("initial"))
    }

    func testSubjectDispatch() {
        let store = CounterStore()
        let subject = store.asSubject()
        var stateReceived: CounterState?

        store.asObservable().subscribeNext { state in
            stateReceived = state
        }.addDisposableTo(disposeBag)

        subject.dispatch(IncrementAction(amount: 3))
        expect(stateReceived?.counter).toEventually(equal(3))
    }

    func testSubjectObservation() {
        let store = CounterStore()
        let subject = store.asSubject()
        var stateReceived: CounterState?

        subject.asObservable().subscribeNext { state in
            stateReceived = state
        }.addDisposableTo(disposeBag)

        store.dispatch(IncrementAction(amount: 5))
        expect(stateReceived?.counter).toEventually(equal(5))
    }

    func testSubscriberIntegration() {
        let subscriber = CounterSubscriber()
        let store = CounterStore()

        store.bindNext(to: subscriber).addDisposableTo(disposeBag)
        store.dispatch(IncrementAction(amount: 4))
        expect(subscriber.counter) == 4
    }
}
