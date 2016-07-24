import Foundation

public final class Store<State>: Publisher, Dispatch {
    private let reduce: (State?, Action) -> State
    
    private var state: State? {
        didSet { publish(state) }
    }
    
    private var subscribers: [String: State -> Void]
    
    public init (reducer: (State?, Action) -> State, initialState: State? = nil) {
        reduce = reducer
        state = initialState
        subscribers = [:]
    }
    
    public func dispatch(action: Action) {
        state = reduce(state, action)
    }
    
    public func subscribe(subscription: State -> Void) -> Void -> Void {
        let token = NSUUID().UUIDString
        subscribers[token] = subscription
        
        if let state = state {
            subscription(state)
        }
        
        return { [weak self] in
            self?.subscribers.removeValueForKey(token)
        }
    }
    
    private func publish(newState: State?) {
        guard let state = newState else {
            return
        }
        subscribers.values.forEach { $0(state) }
    }
}

public protocol Dispatch {
    func dispatch(action: Action)
}

extension Dispatch {
    public func dispatch(thunk: (Action -> Void) -> Void) {
        thunk { self.dispatch($0) }
    }
}

public protocol Action {}

public protocol Publisher {
    associatedtype Publishing
    func subscribe(subscription: Publishing -> Void) -> Void -> Void
}

extension Publisher {
    public func subscribe <T: Subscriber where T.Publishing == Publishing> (subscriber subscriber: T) -> Void -> Void {
        var mutableSubscriber = subscriber
        return subscribe { mutableSubscriber.receive(subscriber.select($0)) }
    }
}

extension Publisher where Self: Dispatch {
    func connection <T: Subscriber where T.Publishing == Publishing> (to subscriber: T) -> StateConnection {
        let dispatch = { self.dispatch($0) }
        let unsubscribe = self.subscribe(subscriber: subscriber)
        return AnyStateConnection(dispatch: dispatch, unsubscribe: unsubscribe)
    }
}

public protocol Subscriber: class {
    associatedtype Publishing
    associatedtype Selection
    
    func select(publishing: Publishing) -> Selection
    func receive(selection: Selection)
}

public protocol StateConnection: Dispatch {
    func unsubscribe()
}

private struct AnyStateConnection: StateConnection {
    private let doDispatch: Action -> Void
    private let doUnsubscribe: Void -> Void
    
    private init (dispatch: Action -> Void, unsubscribe: Void -> Void) {
        doDispatch = dispatch
        doUnsubscribe = unsubscribe
    }
    
    func dispatch(action: Action) {
        doDispatch(action)
    }
    
    func unsubscribe() {
        doUnsubscribe()
    }
}

public protocol StateConnectable {
    mutating func connect(with connection: StateConnection)
}

extension StateConnectable where Self: Subscriber {
    mutating func connect<T: protocol<Publisher, Dispatch> where T.Publishing == Publishing>(to connector: T) {
        connect(with: connector.connection(to: self))
    }
    
    mutating func connected<T: protocol<Publisher, Dispatch> where T.Publishing == Publishing>(to connector: T) -> Self {
        connect(to: connector)
        return self
    }
}
