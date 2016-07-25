import Foundation
import Redux_swift

class IdentificationStore: Publisher, Dispatch {
    private let store = Store<IdentificationState>(initialState: IdentificationState.initial) { state, action in
        switch action {
        case let action as IdentifiedAction:
            return IdentificationState(identifier: action.identifier)
        default:
            return state ?? IdentificationState.initial
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
    
    static var initial: IdentificationState {
        return IdentificationState(identifier: "initial")
    }
}

struct IdentifiedAction: Action {
    let identifier: String
}
