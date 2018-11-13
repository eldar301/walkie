//
//  RecordButton.swift
//  walkie
//
//  Created by Eldar Goloviznin on 08/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let roundRectOffset: CGFloat = 3.0
    static let roundedSquareScale: CGFloat = 0.5
    static let recordedCornerRadius: CGFloat = 5.0
    static let changeStateAnimationDuration = 0.1
}

@IBDesignable
class RecordButton: UIButton {
    
    @IBInspectable var circleLineWidth: CGFloat = 5.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var recording: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var statusLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let newPath = getCurrentRecordingPath()
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = statusLayer.path
        animation.toValue = newPath
        animation.duration = Constants.changeStateAnimationDuration
        statusLayer.add(animation, forKey: nil)
        statusLayer.path = newPath
    }
    
    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY),
                                      radius: (min(rect.width, rect.height) - circleLineWidth) / 2,
                                      startAngle: 0,
                                      endAngle: 2 * .pi,
                                      clockwise: true)
        circlePath.lineWidth = circleLineWidth
        UIColor.white.setStroke()
        circlePath.stroke()
    }
    
    private func setup() {
        let statusLayer = CAShapeLayer()
        statusLayer.fillColor = UIColor.red.cgColor
        statusLayer.path = getCurrentRecordingPath()
        self.layer.addSublayer(statusLayer)
        self.statusLayer = statusLayer
    }
    
    private func getCurrentRecordingPath() -> CGPath {
        if recording {
            let edgeOffset = self.bounds.width * (1 - Constants.roundedSquareScale) / 2
            let roundedSquareWidth = self.bounds.width * Constants.roundedSquareScale
            let roundedSquareRect = CGRect(x: edgeOffset,
                                           y: edgeOffset,
                                           width: roundedSquareWidth,
                                           height: roundedSquareWidth)
            let roundedSquarePath = UIBezierPath(roundedRect: roundedSquareRect, cornerRadius: Constants.recordedCornerRadius)
            return roundedSquarePath.cgPath
        } else {
            let edgeOffset = circleLineWidth + Constants.roundRectOffset
            let roundRect = CGRect(x: edgeOffset,
                                   y: edgeOffset,
                                   width: self.bounds.width - 2 * edgeOffset,
                                   height: self.bounds.height - 2 * edgeOffset)
            let circlePath = UIBezierPath(roundedRect: roundRect,
                                          cornerRadius: roundRect.width / 2)
            return circlePath.cgPath
        }
    }
    
}
