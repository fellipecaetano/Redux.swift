public typealias Middleware<State> = (@escaping () -> State, @escaping Dispatch) -> (@escaping Dispatch) -> Dispatch

public struct Middlewares {
    public static func combine<State>(_ middleware: Middleware<State>...) -> Middleware<State> {
        return combine(middleware)
    }

    public static func combine<State>(_ middleware: [Middleware<State>]) -> Middleware<State> {
        return { getState, dispatch in
            let chain = middleware.map({ middleware in middleware(getState, dispatch) })

            return { dispatch in
                chain.reduce(dispatch) { dispatch, next in next(dispatch) }
            }
        }
    }
}
