//
//  IntroViewController.swift
//  EraseMind
//
//  Created by Jimin Song
//

import UIKit

class IntroViewController: ViewController {
    
    let popUpView = PopUpView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.logo.isHidden = true
        
        view.addSubview(popUpView)
        
        let button = PopUpActionButton()
        button.actionTitle = "ERASE YOUR NAGATIVE MIND!"
        button.addTarget(self, action: #selector(showEnterMoodView), for: .touchUpInside)
        popUpView.addAction(button: button)
        
        let labelFont = Font.font(size: PopUpView.fontSize)
        let text = "Hello there! I know today was a hectic day… but there will be brighter days in the future!\n\nYou can simply type out your mind. Let out everything on your mind here.\n\nLeave with a cleared mind, free from your negative thoughts."
        let attributedText = Font.adjustedAttributedString(text: text, font: labelFont)
        popUpView.attributedTitle = attributedText
        
        popUpView.stackView.insertArrangedSubview(IntroHeaderView(), at: 0)
        
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popUpView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popUpView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        self.popUpView.alpha = 0
        self.popUpView.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration:0.6,
                       delay: 1,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1,
                    options: [],
                    animations: {
                        self.popUpView.alpha = 1
                       self.popUpView.transform = CGAffineTransform.identity
                           }, completion: {
                           //Code to run after animating
                               (value: Bool) in
                       })
    }
    
    @objc func showEnterMoodView() {
        guard let navigationController = navigationController else {
            return
        }
        popUpView.transform = CGAffineTransform.identity
        UIView.animate(withDuration:0.6,
                               delay: 0,
                     usingSpringWithDamping: 0.7,
                     initialSpringVelocity: 1,
                     options: [],
                     animations: {
                        self.popUpView.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
                        self.popUpView.alpha = 0
                            }, completion: { (value: Bool) in
                                navigationController.viewControllers = [EnterMoodViewController()]
                        })
    }
}

class IntroHeaderView: UIView {
    let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "logo")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let label: UILabel = {
        let view = UILabel()
        view.textColor = Theme.black
        view.textAlignment = .center
        view.clipsToBounds = false
        view.font = Font.font(size: 25)
        view.text = "minderaser"
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(label)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
        ])
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 25),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 150, height: 150)
    }
}
