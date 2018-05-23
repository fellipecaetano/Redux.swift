public typealias Middleware<State> = (@escaping () -> State, @escaping Dispatch) -> (@escaping Dispatch) -> Dispatch

struct Middlewares {
    static func combine<State>(_ middleware: [Middleware<State>]) -> Middleware<State> {
        return { getState, dispatch in
            let chain = middleware.map({ middleware in middleware(getState, dispatch) })

            return { dispatch in
                chain.reduce(dispatch) { dispatch, next in next(dispatch) }
            }
        }
    }
}
