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

class CounterView: UIView {
    let bigDecrementButton = UIButton(type: .system)
    let smallDecrementButton = UIButton(type: .system)
    let smallIncrementButton = UIButton(type: .system)
    let bigIncrementButton = UIButton(type: .system)
    let label = UILabel()

    var buttons: [UIButton] {
        return [
            bigDecrementButton,
            smallDecrementButton,
            smallIncrementButton,
            bigIncrementButton
        ]
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        backgroundColor = .white

        for button in buttons {
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.setTitle("+1", for: .normal)
        }

        let buttonsView = UIStackView(arrangedSubviews: buttons)
        buttonsView.axis = .horizontal
        buttonsView.alignment = .center
        buttonsView.spacing = 15
        buttonsView.distribution = .equalSpacing
        buttonsView.translatesAutoresizingMaskIntoConstraints = false

        label.font = UIFont.boldSystemFont(ofSize: 45)
        label.textAlignment = .center
        label.text = "0"

        let contentView = UIStackView(arrangedSubviews: [label, buttonsView])
        contentView.axis = .vertical
        contentView.alignment = .center
        contentView.spacing = 100
        contentView.distribution = .equalSpacing
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        contentView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
