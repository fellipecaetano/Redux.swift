import UIKit
import Redux
import RxSwift
import RxCocoa

class ReactiveCounterViewController: UIViewController {
    @IBOutlet private weak var counterLabel: UILabel!
    var counter: Observable<CounterState> = Observable.empty()
    var dispatcher: Dispatcher!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        counter
            .map({ $0.counter })
            .map(String.init)
            .bindTo(counterLabel.rx.text)
            .addDisposableTo(disposeBag)
    }

    @IBAction func didTapBigDecrement() {
        dispatcher.dispatch(DecrementAction(amount: 5))
    }

    @IBAction func didTapSmallDecrement() {
        dispatcher.dispatch(DecrementAction(amount: 1))
    }

    @IBAction func didTapSmallIncrement() {
        dispatcher.dispatch(IncrementAction(amount: 1))
    }

    @IBAction func didTapBigIncrement() {
        dispatcher.dispatch(IncrementAction(amount: 5))
    }
}
