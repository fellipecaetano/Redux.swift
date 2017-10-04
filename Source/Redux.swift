import Foundation

/**
 Represents a function capable of dispatching Action instances
 */
public typealias Dispatch = (Action) -> Void

/**
 Represents a reducer that acts on state instances of type T
 */
public typealias Reducer<T> = (T, Action) -> T

/**
 The data structure responsible for holding application state, allowing controlled mutation through dispatched
 `Actions` and notifying interested parties that `subscribe` to state changes.
 */
public final class Store<State>: StoreProtocol {
    public private(set) var state: State { didSet { publish(state) } }
    fileprivate let reduce: Reducer<State>
    fileprivate var subscribers = [String: (State) -> Void]()
    fileprivate var dispatcher: Dispatch!

    /**
     Initializes a `Store`.

     - parameter initialState: The initial value of the application state in hold.
     - parameter middleware: A collection of functions that will be run whenever an `Action` is dispatched.
     - parameter reducer: The root pure function that's responsible for transforming state according to `Actions`.
     */
    public init (initialState: State, reducer: @escaping Reducer<State>) {
        self.state = initialState
        self.reduce = reducer
        self.dispatcher = _dispatch(_:)
    }

    /**
     Initializes a `Store`.

     - parameter initialState: The initial value of the application state in hold.
     - parameter middleware: A collection of functions that will be run whenever an `Action` is dispatched.
     - parameter reducer: The root pure function that's responsible for transforming state according to `Actions`.
     */
    public init (initialState: State,
                 reducer: @escaping Reducer<State>,
                 middleware: @escaping Middleware<State>) {
        self.state = initialState
        self.reduce = reducer
        self.dispatcher = middleware({ [unowned self] in self.state }, _dispatch)(_dispatch)
    }

    /**
     Perform state changes described by the action and the root reducer.

     - parameter action: The descriptor of **what** is the state change.
     */
    public func dispatch(_ action: Action) {
        dispatcher(action)
    }

    private func _dispatch(_ action: Action) {
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
    func subscribe(_ subscription: @escaping (State) -> Void) -> (() -> Void)
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

/**
 A wrapper for asynchronous dispatches. Useful for namespacing
 long-running procedures that dispatch many `Action`
 instances asynchronously.
 */
public protocol Command {
    associatedtype State

    /**
     Runs an arbitrary procedure that dispatches `Action` instances
     asynchronously.

     - parameter state: A state accessor. It only makes sense
     when this `Command` is dispatched by a `Store`.
     - parameter dispatch: Dispatches an action.
     */
    func run(state: () -> State, dispatch: @escaping (Action) -> Void)
}

/**
 A command that informs its store of its completion so it can be used
 for testing.
 */
public protocol CompleteableCommand: Command {
    /**
     Runs an arbitrary procedure that dispatches `Action` instances
     asynchronously.
     - parameter state: A state accessor. It only makes sense
     when this `Command` is dispatched by a `Store`.
     - parameter dispatch: Dispatches an action.
     - parameter completion: Optional completion block for when the
     command finished its execution
     */
    func run(state: () -> State, dispatch: @escaping (Action) -> Void, completion: (() -> Void)?)
}

extension CompleteableCommand {
    public func run(state: () -> State, dispatch: @escaping (Action) -> Void) {
        run(state: state, dispatch: dispatch, completion: nil)
    }
}

extension StoreProtocol {
    /**
     Runs a `Command` injecting the current `State` and a handle
     for dispatching `Action` instances from this `StoreProtocol`.

     - parameter command: The `Command` instance that will be run.
     - parameter completion: The completion block to be executed
     when the command finish its execution
     */
    public func dispatch<C: Command>(_ command: C) where C.State == State {
        dispatch { getState, dispatch in
            command.run(state: getState, dispatch: dispatch)
        }
    }

    /**
     Runs a `CompleteableCommand` injecting the current `State` and a handle
     for dispatching `Action` instances from this `StoreProtocol`.
     - parameter command: The `CompleteableCommand` instance that will be run.
     - parameter completion: The completion block to be executed
     when the command finish its execution
     */
    public func dispatch<C: CompleteableCommand>(_ command: C, completion: (() -> Void)? = nil)
        where C.State == State {

            dispatch { getState, dispatch in
                command.run(state: getState, dispatch: dispatch, completion: completion)
            }
    }
}
