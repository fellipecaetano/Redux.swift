import Foundation
import Redux

class IdentificationStore: Publisher, Dispatch {
    private let store = Store<IdentificationState>(initialState: IdentificationState()) { state, action in
        switch action {
        case let action as IdentifiedAction:
            return IdentificationState(identifier: action.identifier)

        default:
            return state
        }
    }

    func subscribe(subscription: IdentificationState -> Void) -> Void -> Void {
        return store.subscribe(subscription)
    }

    func dispatch(action: Action) {
        store.dispatch(action)
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
