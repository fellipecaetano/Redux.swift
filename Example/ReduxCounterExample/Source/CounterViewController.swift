import UIKit
import Redux

class CounterViewController: UIViewController, StateConnectable, Subscriber {
    @IBOutlet private weak var counterLabel: UILabel! {
        didSet {
            counterLabel.text = String(0)
        }
    }
    private var connection: StateConnection?

    deinit {
        connection?.unsubscribe()
    }
    
    func connect(with connection: StateConnection) {
        self.connection = connection
    }
    
    func select(state: CounterState) -> Int {
        return state.counter
    }
    
    func receive(selection: Int) {
        counterLabel?.text = String(selection)
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