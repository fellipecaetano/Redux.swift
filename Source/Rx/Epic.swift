import RxSwift

public typealias Epic<T> = (@escaping () -> T, Observable<Action>) -> Observable<Action>

public struct Epics {
    public static func middleware<T>(_ epics: @escaping Epic<T>...) -> Middleware<T> {
        return middleware(combine(epics))
    }

    public static func middleware<T>(_ epic: @escaping Epic<T>) -> Middleware<T> {
        let actionSubject = PublishSubject<Action>()

        return { getState, dispatch in
            _ = epic(getState, actionSubject.asObservable()).subscribe(onNext: dispatch)

            return { next in { action in
                next(action)
                actionSubject.onNext(action)
            }}
        }
    }

    private static func combine<T>(_ epics: [Epic<T>]) -> Epic<T> {
        return { getState, actions in
            .merge(
                epics.map({ epic in epic(getState, actions) })
            )
        }
    }
}
