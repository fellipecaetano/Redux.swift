import Foundation
import RxSwift

public extension Publisher where Self: ObservableType {
    func subscribe<O: ObserverType where O.E == Publishing>(observer: O) -> Disposable {
        let unsubscribe = subscribe(observer.onNext)
        return AnonymousDisposable(unsubscribe)
    }
}

extension Store: ObservableType {
    public typealias E = State
}

public extension ObservableType {
    @warn_unused_result(message="http://git.io/rxs.ud")
    func bindNext<S: Subscriber where S.Publishing == E>(to subscriber: S) -> Disposable {
        return map(subscriber.select).subscribeNext(subscriber.receive)
    }
}
