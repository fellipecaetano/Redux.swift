import XCTest
import Redux
import RxSwift
import Nimble

class ReduxRxSwiftTests: XCTestCase {
    fileprivate let disposeBag = DisposeBag()

    func testInitialObservation() {
        let observable = IdentificationStore().asObservable()
        var stateReceived: IdentificationState?

        observable.subscribe(onNext: { state in
            stateReceived = state
        }).addDisposableTo(disposeBag)

        expect(stateReceived?.identifier).toEventually(equal("initial"))
    }

    func testDispatchObservations() {
        let store = IdentificationStore()
        var stateReceived: IdentificationState?

        store.asObservable().subscribe(onNext: { state in
            stateReceived = state
        }).addDisposableTo(disposeBag)

        let action = IdentifiedAction(identifier: "observe_this")
        store.dispatch(action)
        expect(stateReceived?.identifier).toEventually(equal(action.identifier))
    }

    func testObservableDisposal() {
        let store = DisposalSpyStore()
        var stateReceived: IdentificationState?

        let disposable = store.asObservable().subscribe(onNext: { state in
            stateReceived = state
        })
        disposable.dispose()

        expect(store.didUnsubscribe).toEventually(beTrue())

        let action = IdentifiedAction(identifier: "observe_this")
        store.dispatch(action)
        expect(stateReceived?.identifier).toEventually(equal("initial"))
    }
}
