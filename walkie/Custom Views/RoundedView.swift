//
//  RoundedView.swift
//  walkie
//
//  Created by Eldar Goloviznin on 07/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 10.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

}
