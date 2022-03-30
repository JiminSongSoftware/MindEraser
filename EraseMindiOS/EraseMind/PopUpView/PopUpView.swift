//
//  PopUpView.swift
//  EraseMind
//
//  Created by Jimin Song
//

import UIKit

let buttonWidth: CGFloat = 278
let buttonHeight: CGFloat = 53
let verticalPadding: CGFloat = 25

class PopUpView: UIView {
    
    var attributedTitle: NSAttributedString? {
        didSet {
            titleLabel.attributedText = attributedTitle
            if let _ = oldValue {
                UIView.animate(withDuration: 0.25) {
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    var buttonTitie: String? {
        didSet {
            actions.first?.setTitle(buttonTitie, for: .normal)
            if let _ = oldValue {
                UIView.animate(withDuration: 0.25) {
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    var actions: [PopUpActionButton] = []
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.textColor = Theme.black
        view.textAlignment = .center
        view.clipsToBounds = false
        return view
    }()
    
    let stackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.spacing = verticalPadding
        view.axis = .vertical
        view.clipsToBounds = false
        return view
    }()
    
    private let buttonStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.spacing = 10
        view.axis = .vertical
        view.clipsToBounds = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.cardBackground
        clipsToBounds = true
        layer.cornerRadius = 14
        layer.borderWidth = 4
        layer.borderColor = Theme.black.cgColor

        addSubview(stackView)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(buttonStackView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalToConstant: 335 - 2 * verticalPadding),
        ])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: verticalPadding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalPadding),
            stackView.widthAnchor.constraint(equalToConstant: 335 - 2 * verticalPadding),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 335, height: stackView.frame.height + 2 * verticalPadding)
    }
    
    func addAction(button: PopUpActionButton) {
        actions.append(button)
        buttonStackView.addArrangedSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func removeAllAcitons() {
        for subview in stackView.arrangedSubviews {
            if let _ = subview as? PopUpActionButton {
                subview.removeFromSuperview()
            }
        }
    }
    
    class var fontSize: CGFloat {
        return 20
    }
}

class PopUpActionButton: UIButton {
    
    let buttonFont = Font.font(size: 18)
    
    var actionTitle: String? {
        didSet {
            guard let actionTitle = actionTitle else {
                setAttributedTitle(nil, for: .normal)
                return
            }
            setAttributedTitle(Font.adjustedAttributedString(text: actionTitle, font: buttonFont), for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setBackgroundImage(UIImage.image(Theme.pinkishWhite), for: .normal)
        setTitleColor(Theme.black, for: .normal)
        clipsToBounds = true
        layer.cornerRadius = 15
        layer.borderWidth = 4
        layer.borderColor = Theme.lightBrown.cgColor
        titleLabel?.font = buttonFont
        self.frame.size = CGSize(width: buttonWidth, height: buttonHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 278, height: 53)
    }
}
