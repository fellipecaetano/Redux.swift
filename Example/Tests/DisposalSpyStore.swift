import Redux
import RxSwift

class DisposalSpyStore: Publisher, Dispatcher, ObservableType {
    typealias E = IdentificationStore.Publishing

    private let store = IdentificationStore()
    private(set) var didUnsubscribe = false

    func subscribe(subscription: IdentificationStore.Publishing -> Void) -> Void -> Void {
        let unsubscribe = store.subscribe(subscription)

        return {
            self.didUnsubscribe = true
            unsubscribe()
        }
    }

    func dispatch(action: Action) {
        store.dispatch(action)
    }
}
