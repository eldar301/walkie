//
//  GraphView.swift
//  walkie
//
//  Created by Eldar Goloviznin on 07/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let totalWeekdaysPresentable = 7
    static let leftMargin: CGFloat = 8.0
    static let graphLeftMargin: CGFloat = 16.0
    static let rightMargin: CGFloat = 40.0
    static let graphRightMargin: CGFloat = 48.0
    static let topMargin: CGFloat = 16.0
    static let bottomMargin: CGFloat = 8.0
    static let graphBottomMargin: CGFloat = 30.0
    static let flashingSelectionWidth: CGFloat = 3.0
}

class GraphView: UIControl {
    
    @IBInspectable var weakdayColor: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var graphColor: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var splitSectionsColor: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var graphLineWidth: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var dotSize: CGSize = CGSize(width: 5.0, height: 5.0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var distancesByDays: [[Int: Double]] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var maximumDistance: Double = 0.0
    
    var pickedIndex: Int?
    
    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        guard let touch = event?.allTouches?.first(where: { $0.phase == .ended }) else {
            super.sendAction(action, to: target, for: event)
            return
        }
        
        let xLocation = touch.location(in: self).x - Constants.graphLeftMargin
        
        let availableWidth = self.bounds.width - Constants.graphLeftMargin - Constants.graphRightMargin
        let widthPerWeekday = availableWidth / CGFloat(Constants.totalWeekdaysPresentable - 1)
        
        pickedIndex = Int(min((xLocation / widthPerWeekday).rounded(.toNearestOrAwayFromZero), CGFloat(Constants.totalWeekdaysPresentable - 1)))
        
        super.sendAction(action, to: target, for: event)
        
        flashSelection()
    }
    
    private func flashSelection() {
        guard let index = pickedIndex else {
            return
        }
        
        let x = calculateGraphX(forDayIndex: index) - Constants.flashingSelectionWidth / 2.0
        let y = calculateGraphY(forDistance: distancesByDays[index].first!.value, whereMaximumIs: maximumDistance)
        
        let height = self.bounds.height - Constants.graphBottomMargin - y
        
        let flashLayer = CALayer()
        flashLayer.frame = CGRect(x: x, y: y, width: Constants.flashingSelectionWidth, height: height)
        flashLayer.opacity = 0.0
        flashLayer.backgroundColor = UIColor.white.cgColor
        
        self.layer.addSublayer(flashLayer)
        
        let flashAnimation = CABasicAnimation(keyPath: "opacity")
        flashAnimation.fromValue = 0.0
        flashAnimation.toValue = 0.3
        flashAnimation.duration = 0.1
        flashAnimation.autoreverses = true
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            flashLayer.removeFromSuperlayer()
        }
        flashLayer.add(flashAnimation, forKey: nil)
        CATransaction.commit()
    }
    
    override func draw(_ rect: CGRect) {
        if let maximumDistance = distancesByDays.max(by: { $0.first!.value < $1.first!.value })?.first?.value {
            self.maximumDistance = maximumDistance
            // Background lines
            let backgroundLinesPath = UIBezierPath()
            backgroundLinesPath.lineWidth = 1.5
            
            let legendValues = [maximumDistance, maximumDistance / 2, 0]

            for value in legendValues {
                let yPosition = calculateGraphY(forDistance: value, whereMaximumIs: maximumDistance)
                
                let font = UIFont(name: "AvenirNext-Regular", size: 10)!
                let attributes = [NSAttributedString.Key.font: font,
                                  NSAttributedString.Key.foregroundColor: graphColor]
                let valueString = "\(DistanceToStringCoverter.stringDistance(fromDistance: value))" as NSString
                valueString.draw(at: CGPoint(x: self.bounds.width - Constants.graphRightMargin + 10,
                                             y: yPosition - valueString.size(withAttributes: attributes).height / 2), withAttributes: attributes)
                
                backgroundLinesPath.move(to: CGPoint(x: Constants.leftMargin, y: yPosition))
                backgroundLinesPath.addLine(to: CGPoint(x: self.bounds.width - Constants.rightMargin, y: yPosition))
            }
                
            UIColor.white.withAlphaComponent(0.2).setStroke()
            backgroundLinesPath.stroke()
            
            // Graph of distances
            let graphPath = UIBezierPath()
            graphPath.lineWidth = graphLineWidth
            
            let firstDistancePoint = CGPoint(x: calculateGraphX(forDayIndex: 0),
                                             y: calculateGraphY(forDistance: distancesByDays.first!.first!.value, whereMaximumIs: maximumDistance))
            graphPath.move(to: firstDistancePoint)
            
            var dots: [UIBezierPath] = []
            
            for (weekdayIndex, distance) in distancesByDays.enumerated() {
                let position = CGPoint(x: calculateGraphX(forDayIndex: weekdayIndex),
                                       y: calculateGraphY(forDistance: distance.first!.value, whereMaximumIs: maximumDistance))
                
                // Graph peak dot
                let dotRect = CGRect(origin: position, size: dotSize).offsetBy(dx: -dotSize.width / 2, dy: -dotSize.height / 2)
                let dot = UIBezierPath(ovalIn: dotRect)
                dots.append(dot)
                
                // Graph
                graphPath.addLine(to: position)
            }
            
            graphColor.setStroke()
            graphColor.setFill()
            graphPath.stroke()
            for dot in dots {
                dot.fill()
            }
        }
        
        // Weakdays
        let font = UIFont(name: "AvenirNext-Regular", size: 12)!
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: graphColor]
        
        let calendar = Calendar.current        
        let weekdays: [NSString] = distancesByDays.map { calendar.shortWeekdaySymbols[$0.keys.first!] as NSString }
        for (index, weekday) in weekdays.enumerated() {
            weekday.draw(at: CGPoint(x: calculateGraphX(forDayIndex: index) - weekday.size(withAttributes: attributes).width / 2,
                                     y: self.bounds.height - Constants.graphBottomMargin + 5), withAttributes: attributes)
        }
    }
    
    private func calculateGraphX(forDayIndex index: Int) -> CGFloat {
        let availableWidth = self.bounds.width - Constants.graphLeftMargin - Constants.graphRightMargin
        let widthPerWeekday = availableWidth / CGFloat(Constants.totalWeekdaysPresentable - 1)
        return widthPerWeekday * CGFloat(index) + Constants.graphLeftMargin
    }
    
    private func calculateGraphY(forDistance distance: Double, whereMaximumIs maximum: Double) -> CGFloat {
        let availableHeight = self.bounds.height - Constants.graphBottomMargin - Constants.topMargin
        
        guard maximum > 0 else {
            return self.bounds.height - Constants.graphBottomMargin
        }
        
        let y = CGFloat(distance / maximum) * availableHeight + Constants.graphBottomMargin
        return self.bounds.height - y
    }
    
    func showError(withMessage message: String) {
        let label = UILabel()
        label.textColor = .white
        label.text = message
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
}
