import UIKit

class CounterViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = CounterView(frame: UIScreen.main.bounds)
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
