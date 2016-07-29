import UIKit
import Redux

class CounterViewController: UIViewController, StateConnectable {
    @IBOutlet private weak var counterLabel: UILabel!
    private var connection: StateConnection?

    func connect(with connection: StateConnection) {
        self.connection = connection
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        connection?.subscribe()
    }

    deinit {
        connection?.unsubscribe()
    }

    @IBAction func didTapBigDecrement() {
        connection?.dispatch(DecrementAction(amount: 5))
    }

    @IBAction func didTapSmallDecrement() {
        connection?.dispatch(DecrementAction(amount: 1))
    }

    @IBAction func didTapSmallIncrement() {
        connection?.dispatch(IncrementAction(amount: 1))
    }

    @IBAction func didTapBigIncrement() {
        connection?.dispatch(IncrementAction(amount: 5))
    }
}

extension CounterViewController: Subscriber {
    func select(state: CounterState) -> Int {
        return state.counter
    }

    func receive(selection: Int) {
        counterLabel.text = String(selection)
    }
}
