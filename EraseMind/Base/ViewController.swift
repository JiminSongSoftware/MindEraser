//
//  ViewController.swift
//  EraseMind
//
//  Created by Jimin Song
//

import UIKit

class ViewController: UIViewController {

    let logo = UIImageView()
    
    var logoTopOffset: CGFloat {
        guard UIScreen.isSmallPhone else {
            return 60
        }
        return 40
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.pink
        
        logo.image = UIImage(named: "logo")
        logo.contentMode = .scaleAspectFit
        view.addSubview(logo)
        
        logo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: view.topAnchor, constant: logoTopOffset),
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.widthAnchor.constraint(equalToConstant: 60),
            logo.heightAnchor.constraint(equalToConstant: 46),
        ])
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.darkContent
    }

}

