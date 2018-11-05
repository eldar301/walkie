//
//  UIViewController+Extension.swift
//  walkie
//
//  Created by Eldar Goloviznin on 04/11/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showError(withMessage message: String) {
        let bottomMessageLabel = UILabel()
        bottomMessageLabel.text = message
        bottomMessageLabel.backgroundColor = .orange
        bottomMessageLabel.textColor = .white
        bottomMessageLabel.textAlignment = .center
        bottomMessageLabel.alpha = 0.0
        bottomMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bottomMessageLabel)
        
        bottomMessageLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        bottomMessageLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        bottomMessageLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        bottomMessageLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        UIView.animate(withDuration: 1.0, animations: {
            bottomMessageLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 1.0, animations: {
                bottomMessageLabel.alpha = 0.0
            }, completion: { _ in
                bottomMessageLabel.removeFromSuperview()
            })
        }
    }
    
}
