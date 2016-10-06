import Redux
import RxSwift

class DisposalSpyStore: Publisher, Dispatcher, ObservableType {
    typealias E = IdentificationStore.Publishing

    fileprivate let store = IdentificationStore()
    fileprivate(set) var didUnsubscribe = false

    func subscribe(_ subscription: @escaping (IdentificationStore.Publishing) -> Void) -> ((Void) -> Void) {
        let unsubscribe = store.subscribe(subscription)

        return {
            self.didUnsubscribe = true
            unsubscribe()
        }
    }

    func dispatch(_ action: Action) {
        store.dispatch(action)
    }
}
