import UIKit
import Redux

class CounterViewController<T: StoreProtocol>: UIViewController where T.State == Int, T.State == T.Publishing {
    private let store: T
    private var unsubscribe: (() -> ())?

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

    override func viewDidAppear(_ animated: Bool) {
        unsubscribe = store.subscribe(render)
    }

    private func render(counter: Int) {
        counterLabel.text = "\(counter)"
    }
}

extension CounterViewController {
    var bigDecrementButton: UIButton {
        return smartView.bigIncrementButton
    }

    var smallDecrementButton: UIButton {
        return smartView.smallDecrementButton
    }

    var smallIncrementButton: UIButton {
        return smartView.smallDecrementButton
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
