import Foundation
import RxSwift

public extension Publisher where Self: ObservableType {
    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == Publishing {
        let unsubscribe = subscribe(observer.onNext)
        return AnonymousDisposable(unsubscribe)
    }
}

extension Store: ObservableType {
    public typealias E = State
}
