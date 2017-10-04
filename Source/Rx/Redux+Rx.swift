import RxSwift

public extension Publisher where Self: ObservableType {
    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == State {
        let unsubscribe = subscribe(observer.onNext)

        return Disposables.create {
            unsubscribe()
        }
    }
}

public extension Dispatcher {
    private func asObserver() -> AnyObserver<Action> {
        return AnyObserver { event in
            if case .next(let action) = event {
                self.dispatch(action)
            }
        }
    }
}

extension Store: ObservableType {
    public typealias E = State
}
