import Foundation
import RxSwift

public extension Publisher where Self: ObservableType {
    func subscribe<O: ObserverType where O.E == Publishing>(observer: O) -> Disposable {
        let unsubscribe = subscribe(observer.onNext)
        return AnonymousDisposable(unsubscribe)
    }
}

public extension Publisher where Self: protocol<ObservableType, Dispatch> {
    func asSubject() -> StateSubject<Publishing> {
        return StateSubject(subscribe: self.subscribe, dispatch: self.dispatch)
    }
}

public struct StateSubject<T>: ObservableType, Dispatch {
    public typealias E = T

    private let doSubscribe: AnyObserver<T> -> Disposable
    private let doDispatch: Action -> Void

    init(subscribe: AnyObserver<T> -> Disposable, dispatch: Action -> Void) {
        doSubscribe = subscribe
        doDispatch = dispatch
    }

    public func subscribe<O: ObserverType where O.E == E>(observer: O) -> Disposable {
        return doSubscribe(AnyObserver(observer))
    }

    public func dispatch(action: Action) {
        doDispatch(action)
    }
}

extension Store: ObservableType {
    public typealias E = State
}

public extension ObservableType {
    @warn_unused_result(message="http://git.io/rxs.ud")
    func bindTo<S: Subscriber where S.Publishing == E>(subscriber: S) -> Disposable {
        return map(subscriber.select).subscribeNext(subscriber.receive)
    }
}
