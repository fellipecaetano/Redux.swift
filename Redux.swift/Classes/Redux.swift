import Foundation

/**
 The data structure responsible for holding application state, allowing controlled mutation through dispatched
 `Actions` and notifying interested parties that `subscribe` to state changes.
 */
public final class Store<State>: Publisher, Dispatch {
    private let reduce: (State, Action) -> State

    private var state: State {
        didSet { publish(state) }
    }

    private var subscribers: [String: State -> Void]

    /**
     Initializes a `Store`.

     - parameter initialState: The initial value of the application state in hold.
     - parameter reducer: The root pure function that's responsible for transforming state according to `Actions`.
    */
    public init (initialState: State, reducer: (State, Action) -> State) {
        reduce = reducer
        state = initialState
        subscribers = [:]
    }

    /**
     Perform state changes described by the action and the root reducer.

     - parameter action: The descriptor of **what** is the state change.
     */
    public func dispatch(action: Action) {
        state = reduce(state, action)
    }

    /**
     Registers a handler that's called when state changes

     - parameter subscription: A closure that's called whenever there's a change to the state in hold.
     - returns: A closure that unsubscribes the provided subscription.
     */
    public func subscribe(subscription: State -> Void) -> (Void -> Void) {
        let token = NSUUID().UUIDString
        subscribers[token] = subscription

        subscription(state)

        return { [weak self] in
            self?.subscribers.removeValueForKey(token)
        }
    }

    private func publish(newState: State) {
        subscribers.values.forEach { $0(newState) }
    }
}

/**
 Defines `Action` dispatch cabalities. Instances conforming to `Dispatch` are expected to know how to
 dispatch `Actions`.
 */

public protocol Dispatch {
    /**
     Dispatches an action.

     - parameter action: The action that'll be dispatched.
    */
    func dispatch(action: Action)
}

extension Dispatch {
    /**
     Executes a closure with an injected `dispatch` function. Useful for asynchronous `Action` dispatching.

     - parameter thunk: The closure that will be executed with an injected `dispatch` function.
     */
    public func dispatch(thunk: (Action -> Void) -> Void) {
        thunk(self.dispatch)
    }
}

/**
 Defines a mutation descriptor. Are typically associated to application actions and operations.
 */
public protocol Action {}

/**
 Instances conforming to `Publisher` are expected to know how to add handlers that are provided with an associated
 object in response to generic events.
 */
public protocol Publisher {
    associatedtype Publishing
    /**
     Adds a handler to a generic event.

     - parameter subscription: The handler that will be called in response to generic events.
     - returns: A closure that unsubscribes the provided subscription.
    */
    func subscribe(subscription: Publishing -> Void) -> Void -> Void
}

extension Publisher {
    /**
     Adds the handler defined by a `Subscriber` that is compatible with the events defined by this `Publisher`.

     - parameter subscriber: The compatible `Subscriber`.
     - returns: A closure that unsubscribes the provided `Subscriber`.
     */
    public func subscribe <T: Subscriber where T.Publishing == Publishing> (subscriber subscriber: T) -> (Void -> Void) {
        return subscribe { newState in
            subscriber.receive(subscriber.select(newState))
        }
    }
}

extension Publisher where Self: Dispatch {
    /**
     Creates a `StateConnection` to a compatible `Subscriber` (i. e. a subscriber that subscribes to changes to the same kind of object published by this `Publisher`).
     A `StateConnection` is an object that knows how to `subscribe()` and `dispatch()`.

     - parameter subscriber: The compatible `Subscriber`.
     - returns: The connection.
    */
    func connection <T: Subscriber where T.Publishing == Publishing> (to subscriber: T) -> StateConnection {
        let dispatch = { self.dispatch($0) }
        let subscribe = { self.subscribe(subscriber: subscriber) }
        return AnyStateConnection(subscribe: subscribe, dispatch: dispatch)
    }
}

/**
 Instances conforming to `Subscriber` receive objects of an `associatedtype` associated to generic updates.
 Plus, they should be able to select some portion of this associated object, producing a second associated
 object of another `associatedtype`.
 */
public protocol Subscriber: class {
    associatedtype Publishing
    associatedtype Selection

    /**
     Selects some portion of an object of an arbitrary (associated) type.

     - parameter publishing: The object that will suffer the selection.
     - returns: An object selected from `publishing`.
    */
    func select(publishing: Publishing) -> Selection

    /**
     Receives an object associated to a generic update, preferably after undergoing selection by `select`.

     - parameter selection: The object associated to a generic update, after going through selection.
     */
    func receive(selection: Selection)
}

/**
 An object that knows how to `subscribe()` and `dispatch()`
 */
public protocol StateConnection: Dispatch {
    /**
     Typically used to subscribe a previously associated `Subscriber` to changes published by the
     `Publisher` that created this `StateConnection`.

     - returns: A handle that unsubscribes the previously associated `Subscriber`.
    */
    func subscribe() -> (Void -> Void)
}

private struct AnyStateConnection: StateConnection {
    private let doSubscribe: Void -> (Void -> Void)
    private let doDispatch: Action -> Void

    private init (subscribe: Void -> (Void -> Void), dispatch: Action -> Void) {
        doDispatch = dispatch
        doSubscribe = subscribe
    }

    func subscribe() -> (Void -> Void) {
        return doSubscribe()
    }

    func dispatch(action: Action) {
        doDispatch(action)
    }
}

/**
 Instances conforming to `StateConnectable` are expected to know how to receive a `StateConnection` instance.
 */
public protocol StateConnectable: class {
    /**
     Receives a connection.

     - parameter connection: The connection to receive.
    */
    func connect(with connection: StateConnection)
}

extension StateConnectable where Self: Subscriber {
    /**
     Receives a connection created by a connection creator.

    - parameter connector: The connection creator.
    */
    public func connect<T: protocol<Publisher, Dispatch> where T.Publishing == Publishing>(to connector: T) {
        connect(with: connector.connection(to: self))
    }

    /**
     Connects and returns this `StateConnectable` to a connection creator.

     - parameter connector: The connection creator.
     - returns: This `StateConnectable` after receiving the connection.
    */
    public func connected<T: protocol<Publisher, Dispatch> where T.Publishing == Publishing>(to connector: T) -> Self {
        connect(to: connector)
        return self
    }
}
