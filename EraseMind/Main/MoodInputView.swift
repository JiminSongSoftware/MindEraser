//
//  MoodInputView.swift
//  EraseMind
//
//  Created by Jimin Song
//

import UIKit

protocol MoodInputViewDelegate: class {
    func moodInputView(inputView: MoodInputView, didEnterMood mood: String?)
}

class MoodInputView: UIView {
    
    static let inputViewHeight: CGFloat = 35
    
    weak var delegate: MoodInputViewDelegate?
    
    let arrowButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "icon_arrow_up"), for: .normal)
        view.setImage(UIImage(named: "icon_arrow_up")?.imageWithOverlayColor(color: Theme.pinkishWhite), for: .highlighted)
        view.frame = CGRect(x: 0, y: 0, width: inputViewHeight, height: inputViewHeight)
        view.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        view.addTarget(self, action: #selector(addButtonTouchDown), for: .touchDown)
        view.addTarget(self, action: #selector(addButtonTouchUp), for: .touchUpInside)
        view.addTarget(self, action: #selector(addButtonTouchUp), for: .touchUpOutside)
        return view
    }()
    
    let textField: InputView = {
        let view = InputView()
        view.rightViewMode = .always
        view.font = Font.font(size: 12)
        view.textColor = Theme.black
        view.tintColor = Theme.black
        view.placeholder = "TYPE OUT YOUR NEGATIVE MIND HERE!"
        view.autocorrectionType = .no
        return view
    }()
    
    let textFieldBackgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = Theme.black.cgColor
        view.backgroundColor = Theme.pink
        return view
     }()
    
    let shadowView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = Theme.lightBrown
        view.alpha = 0.6
        return view
    }()
    
    let shadowViewBorder: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = Theme.black.cgColor
        view.backgroundColor = .clear
        return view
    }()
    
    var textFieldBackgroundBottomConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textField.rightView = arrowButton

        addSubview(shadowView)
        shadowView.addSubview(shadowViewBorder)
        addSubview(textFieldBackgroundView)
        textFieldBackgroundView.addSubview(textField)

        textFieldBackgroundBottomConstraint = textFieldBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        textFieldBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textFieldBackgroundView.heightAnchor.constraint(equalToConstant: MoodInputView.inputViewHeight),
            textFieldBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textFieldBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textFieldBackgroundBottomConstraint!,
        ])
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: MoodInputView.inputViewHeight),
            textField.leadingAnchor.constraint(equalTo: textFieldBackgroundView.leadingAnchor, constant: 15),
            textField.trailingAnchor.constraint(equalTo: textFieldBackgroundView.trailingAnchor),
            textField.centerYAnchor.constraint(equalTo: textFieldBackgroundView.centerYAnchor),
        ])
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shadowView.heightAnchor.constraint(equalToConstant: MoodInputView.inputViewHeight),
            shadowView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: trailingAnchor),
            shadowView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        shadowViewBorder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shadowViewBorder.heightAnchor.constraint(equalTo: shadowView.heightAnchor),
            shadowViewBorder.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
            shadowViewBorder.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
            shadowViewBorder.centerYAnchor.constraint(equalTo: shadowView.centerYAnchor),
        ])
        
        shadowView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textFieldBackgroundView.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 2 * 32, height: MoodInputView.inputViewHeight + 10)
    }
    
    @objc func addButtonTapped() {
        guard let text = textField.text, text.count > 0 else {
            return
        }
        delegate?.moodInputView(inputView: self, didEnterMood: text)
        textField.text = nil
    }
    
    @objc func addButtonTouchDown() {
        guard let text = textField.text, text.count > 0 else {
            return
        }
        textFieldBackgroundBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func addButtonTouchUp() {
        textFieldBackgroundBottomConstraint?.constant = -10
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
}

class InputView: UITextField {

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - bounds.height, y: 0, width: bounds.height , height: bounds.height)
    }
}
