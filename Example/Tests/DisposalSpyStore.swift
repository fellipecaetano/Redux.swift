import Redux

class DisposalSpyStore: Publisher, Dispatcher {
    typealias E = IdentificationStore.State

    fileprivate let store = IdentificationStore()
    fileprivate(set) var didUnsubscribe = false

    func subscribe(_ subscription: @escaping (IdentificationStore.State) -> Void) -> ((Void) -> Void) {
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
