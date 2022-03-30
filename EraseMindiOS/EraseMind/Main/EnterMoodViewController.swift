//
//  EnterMoodViewController.swift
//  EraseMind
//
// Created by Jimin Song
//

import UIKit

enum TutorialPhase {
    case none, phase1, phase2, phase3, done
    
    var title: String {
        switch self {
        case .none, .phase1:
            return "type out your mind here\nand tap arrow!"
        case .phase2:
            return "your mind will be here.\nusing minderaser,\nyou can erase your\nnegative thoughts."
        case .phase3, .done:
            return "your negative thoughts\nwill disappear slowly\nwithin 3 days here!"
        }
    }
    
    var attributedTitle: NSAttributedString {
        let labelFont = Font.font(size: PopUpView.fontSize)
        return Font.adjustedAttributedString(text: self.title, font: labelFont)
    }
    
    var buttonTitle: String {
        switch self {
        case .none, .phase1:
            return "got it!"
        case .phase2:
            return "awesome!"
        case .phase3, .done:
            return "i’m ready!"
        }
    }
}

class EnterMoodViewController: ViewController {

    let inputViewSidePadding: CGFloat = 32
    
    var inputViewBottomConstraint: NSLayoutConstraint?
    let moodInputView = MoodInputView()

    var keyboardFrame: CGRect?
    
    var magnetic: Magnetic?
    var magneticView: MagneticView?
    
    let popUpView = PopUpView()
    var currentTutorialPhase: TutorialPhase = .none
    
    let removePopUpView = PopUpView()
    var nodeToRemove: Node?
    
    let feelGoodPopUp = PopUpView()
    
    let feedButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(feedDemo), for: .touchUpInside)
        return view
    }()
    
    let popUpBackgroundOverly: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.4
        return view
    }()
    let tutorialArrow: UIImageView = {
       let view = UIImageView()
        view.image = UIImage(named: "tutorial_arrow")
        view.frame.size = CGSize(width: 37, height: 37)
        return view
    }()
    let tutorialLabel: UILabel = {
       let view = UILabel()
        view.text = "TYPE OUT YOUR NEGATIVE MIND HERE!"
        view.font = Font.font(size: 15)
        view.textColor = Theme.black
        return view
    }()
    
    override func loadView() {
            super.loadView()
            magneticView = MagneticView(frame: self.view.bounds)
            magnetic = magneticView?.magnetic
            magnetic?.magneticDelegate = self
        if let magneticView = magneticView {
            self.view.addSubview(magneticView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moodInputView.delegate = self
        
        view.addSubview(popUpBackgroundOverly)
        view.addSubview(moodInputView)
        view.addSubview(popUpView)
        view.addSubview(tutorialArrow)
        view.addSubview(tutorialLabel)
        view.addSubview(feedButton)
        tutorialLabel.sizeToFit()
        
        let button = PopUpActionButton()
        button.addTarget(self, action: #selector(moveToNextTutorial), for: .touchUpInside)
        popUpView.addAction(button: button)

        moveToNextTutorial()
        
        popUpView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popUpView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popUpView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        inputViewBottomConstraint = moodInputView.bottomAnchor.constraint(equalTo: view.safeLayoutGuideBottomAnchor, constant: inputViewSidePadding)
        moodInputView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            moodInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inputViewSidePadding),
            moodInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inputViewSidePadding),
            inputViewBottomConstraint!,
        ])
        
        feedButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feedButton.leadingAnchor.constraint(equalTo: self.logo.leadingAnchor),
            feedButton.trailingAnchor.constraint(equalTo: self.logo.trailingAnchor),
            feedButton.topAnchor.constraint(equalTo: self.logo.topAnchor),
            feedButton.bottomAnchor.constraint(equalTo: self.logo.bottomAnchor),
        ])
        
        let notifier = NotificationCenter.default
        notifier.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        notifier.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        
        popUpView.alpha = 0
        popUpView.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
        logo.alpha = 0
        popUpBackgroundOverly.alpha = 0
        tutorialArrow.alpha = 0
        tutorialLabel.alpha = 0
        view.layoutIfNeeded()
    }
    
    let feeds: [String] = [
        "can we win the hackathon. What if not",
        "sunny ignored my text! what’s wrong with her!!",
        "i hate my boyfriend! he is always rude!",
        "i’m A total failure..i don’t want to live!!",
        "what if my project is failed..what should i do?!",
    ]
    
    var currentIndex: Int = 0
    
    @objc func feedDemo() {
        guard currentIndex < feeds.count else {
            return
        }
        let text = feeds[currentIndex]
        moodInputView.textField.text = text
        currentIndex += 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputViewBottomConstraint?.constant = -inputViewSidePadding
        UIView.animate(withDuration:0.6,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1,
                    options: [],
                    animations: {
                        self.logo.alpha = 1
                        self.view.layoutIfNeeded()
                           }, completion: {
                           //Code to run after animating
                               (value: Bool) in
                            self.animateInPopUp()
                       })
    }
    
    func animateInPopUp() {
        UIView.animate(withDuration:0.6,
                       delay: 0.2,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1,
                    options: [],
                    animations: {
                        self.popUpBackgroundOverly.alpha = 0.4
                        self.tutorialArrow.alpha = 1
                        self.popUpView.alpha = 1
                        self.popUpView.transform = CGAffineTransform.identity
                           }, completion: {
                           //Code to run after animating
                               (value: Bool) in
                       })
    }
    
    @objc func moveToNextTutorial() {
        guard currentTutorialPhase != .phase3 else {
            popUpBackgroundOverly.removeFromSuperview()
            start()
            return
        }
        if (currentTutorialPhase == .none) {
            currentTutorialPhase = .phase1
            tutorialLabel.alpha = 0
        } else if (currentTutorialPhase == .phase1) {
            currentTutorialPhase = .phase2
            tutorialLabel.alpha = 1
            view.insertSubview(popUpBackgroundOverly, aboveSubview: moodInputView)
        } else if (currentTutorialPhase == .phase2) {
            tutorialLabel.alpha = 0.6
            currentTutorialPhase = .phase3
        } else if (currentTutorialPhase == .phase3) {
            currentTutorialPhase = .done
            start()
        }

        popUpView.buttonTitie = currentTutorialPhase.buttonTitle
        popUpView.attributedTitle = self.currentTutorialPhase.attributedTitle
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        popUpBackgroundOverly.frame = view.bounds
        if (currentTutorialPhase == .phase1) {
            tutorialArrow.center = CGPoint(x: view.frame.width / 2, y: moodInputView.frame.midY - 60)
        } else if (currentTutorialPhase == .phase2 || currentTutorialPhase == .phase3) {
            tutorialArrow.center = CGPoint(x: view.frame.width / 2, y: moodInputView.frame.midY - 130)
            tutorialLabel.center.x = tutorialArrow.center.x
            tutorialLabel.center.y = tutorialArrow.center.y + tutorialLabel.frame.size.height + 30
        }
    }
    
    func start() {
        UIView.animate(withDuration:0.6,
                       delay: 0.2,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1,
                    options: [],
                    animations: {
                        self.moodInputView.alpha = 1
                        self.popUpView.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
                        self.popUpView.alpha = 0
                        self.popUpBackgroundOverly.alpha = 0
                        self.tutorialLabel.alpha = 0
                        self.tutorialArrow.alpha = 0
                           }, completion: {
                           //Code to run after animating
                               (value: Bool) in
                            self.moodInputView.textField.becomeFirstResponder()
                            self.popUpView.removeFromSuperview()
                            self.popUpBackgroundOverly.removeFromSuperview()
                            self.tutorialLabel.removeFromSuperview()
                            self.tutorialArrow.removeFromSuperview()
                       })
    }
    
    @objc func keyboardWillShowNotification(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        let keyboardFrame =  frame.cgRectValue
        self.keyboardFrame = keyboardFrame
        inputViewBottomConstraint?.constant = -keyboardFrame.height - 15 + view.safeAreaInsets.bottom

        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height - keyboardFrame.height - moodInputView.frame.height - 15 - 15
        magneticView?.frame.size = CGSize(width: viewWidth, height: viewHeight)
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in
        }
    }

    @objc func keyboardWillHideNotification(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        inputViewBottomConstraint?.constant = inputViewSidePadding + moodInputView.frame.height
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in
        }
    }
}

extension EnterMoodViewController: MoodInputViewDelegate {
    func moodInputView(inputView: MoodInputView, didEnterMood mood: String?) {
        addLabelToRandomPosition(text: mood)
    }
    
    func addLabelToRandomPosition(text: String?) {
        guard let text = text else {
            return
        }
        let node = Node(text: text, color: .clear)
        node.scaleToFitContent = true
        node.timestamp = Date().timeIntervalSince1970
        magnetic?.addChild(node)
    }
}

extension EnterMoodViewController: MagneticDelegate {
    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {
        showRemovePopUp(for: node)
    }
    
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
        showRemovePopUp(for: node)
    }
    
    func magnetic(_ magnetic: Magnetic, didRemove node: Node) {
        if magnetic.children.count == 0 {
            showFeelGoodPopUp()
        }
    }
    
    func showFeelGoodPopUp() {
        if feelGoodPopUp.actions.count == 0 {
            let labelFont = Font.font(size: PopUpView.fontSize)
            feelGoodPopUp.attributedTitle = Font.adjustedAttributedString(text: "you just let it out all your negative minds! how you feel now?!", font: labelFont)
            
            let actionButton = PopUpActionButton()
            actionButton.setTitle("😋 i feel good! 😋", for: .normal)
            feelGoodPopUp.addAction(button: actionButton)
        }

        popUpBackgroundOverly.alpha = 0.4
        view.addSubview(popUpBackgroundOverly)
        view.addSubview(feelGoodPopUp)
        
        feelGoodPopUp.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            feelGoodPopUp.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feelGoodPopUp.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        view.layoutIfNeeded()
        moodInputView.textField.resignFirstResponder()
        
        feelGoodPopUp.alpha = 0
        feelGoodPopUp.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration:0.6,
                       delay: 0.2,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1,
                    options: [],
                    animations: {
                        self.moodInputView.alpha = 0
                        self.feelGoodPopUp.alpha = 1
                        self.feelGoodPopUp.transform = CGAffineTransform.identity
                           }, completion: {
                           //Code to run after animating
                               (value: Bool) in
                       })
    }
    

    func showRemovePopUp(for node: Node) {
        nodeToRemove = node

        let labelFont = Font.font(size: PopUpView.fontSize)
        removePopUpView.attributedTitle = Font.adjustedAttributedString(text: node.text!, font: labelFont)

        if removePopUpView.actions.count == 0 {
            let removeButton = PopUpActionButton()
            removeButton.addTarget(self, action: #selector(removeNode), for: .touchUpInside)
            removeButton.setTitle("ERASE", for: .normal)
            removePopUpView.addAction(button: removeButton)
            
            let cancelButton = PopUpActionButton()
            cancelButton.addTarget(self, action: #selector(cancelRemove), for: .touchUpInside)
            cancelButton.setTitle("CANCEL", for: .normal)
            removePopUpView.addAction(button: cancelButton)
        }

        popUpBackgroundOverly.alpha = 0.4
        view.addSubview(popUpBackgroundOverly)
        view.addSubview(removePopUpView)
        
        removePopUpView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            removePopUpView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            removePopUpView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        view.layoutIfNeeded()
        moodInputView.textField.resignFirstResponder()
        
        removePopUpView.alpha = 0
        removePopUpView.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration:0.6,
                       delay: 0.2,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1,
                    options: [],
                    animations: {
                        self.moodInputView.alpha = 0
                        self.removePopUpView.alpha = 1
                        self.removePopUpView.transform = CGAffineTransform.identity
                           }, completion: {
                           //Code to run after animating
                               (value: Bool) in
                       })
    }
    
    @objc func removeNode() {
        nodeToRemove?.removeFromParent()
        nodeToRemove = nil
        UIView.animate(withDuration:0.6,
                       delay: 0.2,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1,
                    options: [],
                    animations: {
                        self.moodInputView.alpha = 1
                        self.removePopUpView.alpha = 0
                        self.removePopUpView.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
                        self.popUpBackgroundOverly.alpha = 0
                           }, completion: {
                           //Code to run after animating
                               (value: Bool) in
                            self.removePopUpView.removeFromSuperview()
                            self.popUpBackgroundOverly.removeFromSuperview()
                            self.moodInputView.textField.becomeFirstResponder()
                            if let magnetic = self.magnetic, magnetic.children.count == 0 {
                                self.showFeelGoodPopUp()
                            }
                       })
    }
    
    @objc func cancelRemove() {
        nodeToRemove = nil
        UIView.animate(withDuration:0.6,
                       delay: 0.2,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1,
                    options: [],
                    animations: {
                        self.moodInputView.alpha = 1
                        self.removePopUpView.alpha = 0
                        self.removePopUpView.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
                        self.popUpBackgroundOverly.alpha = 0
                           }, completion: {
                           //Code to run after animating
                               (value: Bool) in
                            self.removePopUpView.removeFromSuperview()
                            self.popUpBackgroundOverly.removeFromSuperview()
                            self.moodInputView.textField.becomeFirstResponder()
                       })
    }
}
