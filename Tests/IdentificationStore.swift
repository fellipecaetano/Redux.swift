import Foundation
import Redux

class IdentificationStore: StoreProtocol {
    fileprivate let store: Store<IdentificationState>

    init (middleware: [Middleware<IdentificationState>] = []) {
        store = Store<IdentificationState>(initialState: IdentificationState(),
                                           middleware: middleware) { state, action in
            switch action {
            case let action as IdentifiedAction:
                return IdentificationState(identifier: action.identifier)
            default:
                return state
            }
        }
    }

    func subscribe(_ subscription: @escaping (IdentificationState) -> Void) -> (() -> Void) {
        return store.subscribe(subscription)
    }

    func dispatch(_ action: Action) {
        store.dispatch(action)
    }

    var state: IdentificationState {
        return store.state
    }
}

struct IdentificationState {
    let identifier: String

    init (identifier: String = "initial") {
        self.identifier = identifier
    }
}

struct IdentifiedAction: Action {
    let identifier: String
}
