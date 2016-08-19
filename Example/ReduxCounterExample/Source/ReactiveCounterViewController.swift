import UIKit
import Redux
import RxSwift

class ReactiveCounterViewController: UIViewController {
    @IBOutlet private weak var counterLabel: UILabel!
    var subject: StateSubject<CounterState>?
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        subject?.bindNext(to: self).addDisposableTo(disposeBag)
    }

    @IBAction func didTapBigDecrement() {
        subject?.dispatch(DecrementAction(amount: 5))
    }

    @IBAction func didTapSmallDecrement() {
        subject?.dispatch(DecrementAction(amount: 1))
    }

    @IBAction func didTapSmallIncrement() {
        subject?.dispatch(IncrementAction(amount: 1))
    }

    @IBAction func didTapBigIncrement() {
        subject?.dispatch(IncrementAction(amount: 5))
    }
}

extension ReactiveCounterViewController: Subscriber {
    func select(state: CounterState) -> Int {
        return state.counter
    }

    func receive(selection: Int) {
        counterLabel.text = String(selection)
    }
}
