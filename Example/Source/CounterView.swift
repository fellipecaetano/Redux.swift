import UIKit

class CounterView: UIView {
    let bigDecrementButton = UIButton(type: .system)
    let smallDecrementButton = UIButton(type: .system)
    let smallIncrementButton = UIButton(type: .system)
    let bigIncrementButton = UIButton(type: .system)
    let counterLabel = UILabel()

    private var buttons: [UIButton] {
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

        setupButton(bigDecrementButton, withTitle: "-5")
        setupButton(smallDecrementButton, withTitle: "-1")
        setupButton(smallIncrementButton, withTitle: "+1")
        setupButton(bigIncrementButton, withTitle: "+5")

        let buttonsView = UIStackView(arrangedSubviews: buttons)
        setupButtonsView(buttonsView)

        setupCounterLabel(counterLabel)

        let contentView = UIStackView(arrangedSubviews: [counterLabel, buttonsView])
        setupContentView(contentView)
    }

    private func setupButton(_ button: UIButton, withTitle title: String) {
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.setTitle(title, for: .normal)
    }

    private func setupButtonsView(_ buttonsView: UIStackView) {
        buttonsView.axis = .horizontal
        buttonsView.alignment = .center
        buttonsView.spacing = 15
        buttonsView.distribution = .equalSpacing
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupCounterLabel(_ counterLabel: UILabel) {
        counterLabel.font = UIFont.boldSystemFont(ofSize: 45)
        counterLabel.textAlignment = .center
    }

    private func setupContentView(_ contentView: UIStackView) {
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
