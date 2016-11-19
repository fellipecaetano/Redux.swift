import Foundation

/**
 The data structure responsible for holding application state, allowing controlled mutation through dispatched
 `Actions` and notifying interested parties that `subscribe` to state changes.
 */
public final class Store<State>: StoreProtocol {
    fileprivate let reduce: (State, Action) -> State

    public private(set) var state: State {
        didSet { publish(state) }
    }

    fileprivate var subscribers: [String: (State) -> Void]

    /**
     Initializes a `Store`.

     - parameter initialState: The initial value of the application state in hold.
     - parameter reducer: The root pure function that's responsible for transforming state according to `Actions`.
    */
    public init (initialState: State, reducer: @escaping (State, Action) -> State) {
        reduce = reducer
        state = initialState
        subscribers = [:]
    }

    /**
     Perform state changes described by the action and the root reducer.

     - parameter action: The descriptor of **what** is the state change.
     */
    public func dispatch(_ action: Action) {
        state = reduce(state, action)
    }

    /**
     Registers a handler that's called when state changes

     - parameter subscription: A closure that's called whenever there's a change to the state in hold.
     - returns: A closure that unsubscribes the provided subscription.
     */
    public func subscribe(_ subscription: @escaping (State) -> Void) -> (() -> Void) {
        let token = UUID().uuidString
        subscribers[token] = subscription

        subscription(state)

        return { [weak self] in
            _ = self?.subscribers.removeValue(forKey: token)
        }
    }

    fileprivate func publish(_ newState: State) {
        subscribers.values.forEach { $0(newState) }
    }
}

/**
 Defines `Action` dispatch capabilities. Instances conforming to `Dispatcher` are expected to know how to
 dispatch `Actions`.
 */

public protocol Dispatcher {
    /**
     Dispatches an action.

     - parameter action: The action that'll be dispatched.
    */
    func dispatch(_ action: Action)
}

extension Dispatcher {
    /**
     Executes a closure with an injected `dispatch` function.
     Useful for asynchronous `Action` dispatches.

     - parameter thunk: The closure that will be executed with an injected `dispatch` function.
     */
    public func dispatch(_ thunk: (@escaping (Action) -> Void) -> Void) {
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
    associatedtype State

    /**
     Adds a handler to a generic event.

     - parameter subscription: The handler that will be called in response to generic events.
     - returns: A closure that unsubscribes the provided subscription.
    */
    func subscribe(_ subscription: @escaping (State) -> Void) -> ((Void) -> Void)
}

/**
 Defines behavior exposed by a Redux store, i. e. action dispatching capabilities 
 and notifications of state changes to subscribers.
 */
public protocol StoreProtocol: Publisher, Dispatcher {
    /**
     Returns the current `State` of the store.
    */
    var state: State { get }
}

extension StoreProtocol {
    /**
     Executes a closure injected with a `dispatch` function and an
     accessor for the current `State`.

     Useful for asynchronous `Action` dispatches that depend on the current
     `State` to perform logic before dispatching actions.
     
     - parameter thunk: The closure that will be executed injected with a `dispatch` function
     and a `State` getter.
     */
    public func dispatch(_ thunk: (@escaping () -> State, @escaping (Action) -> Void) -> Void) {
        let getState = { self.state }
        thunk(getState, dispatch)
    }
}

extension StoreProtocol {
    /**
     Maps this store into a store with the same dispatch capabilities
     but with a transformed `State`.
     
     Useful for selecting branches of a larger `State` tree.

     - parameter transform: The transformation that will be applied to the
     current `State`.
     - returns: a store with the same dispatch capabilities that publishes
     `T` instead of `State`.
    */
    public func map<T>(_ transform: @escaping (State) -> T) -> AnyStore<T> {
        func subscribe(_ subscription: @escaping (T) -> Void) -> ((Void) -> Void) {
            return self.subscribe { state in
                subscription(transform(state))
            }
        }

        func dispatch(_ action: Action) {
            self.dispatch(action)
        }

        func getState() -> T {
            return transform(self.state)
        }

        return AnyStore(subscribe: subscribe, dispatch: dispatch, getState: getState)
    }
}

/**
 A type-erased `StoreProtocol` conformance.
 */
public struct AnyStore<T>: StoreProtocol {
    private let doSubscribe: (@escaping (T) -> Void) -> (() -> Void)
    private let doDispatch: (Action) -> Void
    private let getState: () -> T

    fileprivate init (subscribe: @escaping (@escaping (T) -> Void) -> (() -> Void),
                      dispatch: @escaping (Action) -> Void,
                      getState: @escaping () -> T) {
        self.doSubscribe = subscribe
        self.doDispatch = dispatch
        self.getState = getState
    }

    public func subscribe(_ subscription: @escaping (T) -> Void) -> (() -> Void) {
        return doSubscribe(subscription)
    }

    public func dispatch(_ action: Action) {
        doDispatch(action)
    }

    public var state: T {
        return getState()
    }
}
