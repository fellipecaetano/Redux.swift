import RxSwift

public extension Publisher where Self: ObservableType {
    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.Element == State {
        let unsubscribe = subscribe(observer.onNext)

        return Disposables.create {
            unsubscribe()
        }
    }
}

public extension Dispatcher {
    func asObserver() -> AnyObserver<Action> {
        return AnyObserver { event in
            if case .next(let action) = event {
                self.dispatch(action)
            }
        }
    }
}

extension Store: ObservableType {
    public typealias Element = State
}
