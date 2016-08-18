import Foundation
import RxSwift

public extension Publisher where Self: ObservableType {
    func subscribe<O: ObserverType where O.E == Publishing>(observer: O) -> Disposable {
        let unsubscribe = subscribe { state in
            observer.onNext(state)
        }
        return AnonymousDisposable(unsubscribe)
    }
}
