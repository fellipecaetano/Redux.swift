import UIKit
import Redux

class CounterViewController<T: StoreProtocol>: UIViewController where T.State == Int {
    private let store: T
    private var unsubscribe: (() -> Void)?

    init(store: T) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = CounterView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        bigDecrementButton.addTarget(self, action: #selector(didTapBigDecrementButton), for: .touchUpInside)
        smallDecrementButton.addTarget(self, action: #selector(didTapSmallDecrementButton), for: .touchUpInside)
        smallIncrementButton.addTarget(self, action: #selector(didTapSmallIncrementButton), for: .touchUpInside)
        bigIncrementButton.addTarget(self, action: #selector(didTapBigIncrementButton), for: .touchUpInside)
    }

    @objc private func didTapBigDecrementButton(_ button: UIButton) {
        decrement(amount: 5)
    }

    @objc private func didTapSmallDecrementButton(_ button: UIButton) {
        decrement(amount: 1)
    }

    @objc private func didTapSmallIncrementButton(_ button: UIButton) {
        increment(amount: 1)
    }

    @objc private func didTapBigIncrementButton(_ button: UIButton) {
        increment(amount: 5)
    }

    private func increment(amount: Int) {
        store.dispatch(IncrementAction(amount: amount))
    }

    private func decrement(amount: Int) {
        store.dispatch(DecrementAction(amount: amount))
    }

    override func viewDidAppear(_ animated: Bool) {
        unsubscribe = store.subscribe(render)
    }

    override func viewDidDisappear(_ animated: Bool) {
        unsubscribe?()
    }

    private func render(counter: Int) {
        counterLabel.text = "\(counter)"
    }
}

extension CounterViewController {
    var bigDecrementButton: UIButton {
        return smartView.bigDecrementButton
    }

    var smallDecrementButton: UIButton {
        return smartView.smallDecrementButton
    }

    var smallIncrementButton: UIButton {
        return smartView.smallIncrementButton
    }

    var bigIncrementButton: UIButton {
        return smartView.bigIncrementButton
    }

    var counterLabel: UILabel {
        return smartView.counterLabel
    }

    var smartView: CounterView {
        guard let smartView = view as? CounterView else {
            fatalError("Expected view of type \(CounterView.self) but got \(type(of: view))")
        }
        return smartView
    }
}
