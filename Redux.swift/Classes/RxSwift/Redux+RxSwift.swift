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
