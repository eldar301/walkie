//
//  GraphView.swift
//  walkie
//
//  Created by Eldar Goloviznin on 07/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    struct Graph {
        static let totalWeekdaysPresentable = 7
        static let leftMargin: CGFloat = 8.0
        static let graphLeftMargin: CGFloat = 16.0
        static let rightMargin: CGFloat = 40.0
        static let graphRightMargin: CGFloat = 48.0
        static let topMargin: CGFloat = 16.0
        static let bottomMargin: CGFloat = 8.0
        static let graphBottomMargin: CGFloat = 30.0
        static let backgroundLineWidth: CGFloat = 1.5
        static let weekdaysFont = UIFont(name: "AvenirNext-Regular", size: 12)!
        static let legendValuesFont = UIFont(name: "AvenirNext-Regular", size: 10)!
    }
    struct FlashAnimation {
        static let property = "opacity"
        static let flashingSelectionWidth: CGFloat = 3.0
        static let desiredOpacity = 0.3
        static let duration = 0.1
    }
    
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
        
        let xLocation = touch.location(in: self).x - Constants.Graph.graphLeftMargin
        
        let availableWidth = self.bounds.width - Constants.Graph.graphLeftMargin - Constants.Graph.graphRightMargin
        let widthPerWeekday = availableWidth / CGFloat(Constants.Graph.totalWeekdaysPresentable - 1)
        
        pickedIndex = Int(min((xLocation / widthPerWeekday).rounded(.toNearestOrAwayFromZero), CGFloat(Constants.Graph.totalWeekdaysPresentable - 1)))
        
        super.sendAction(action, to: target, for: event)
        
        flashSelection()
    }
    
    private func flashSelection() {
        guard let index = pickedIndex else {
            return
        }
        
        let x = calculateGraphX(forDayIndex: index) - Constants.FlashAnimation.flashingSelectionWidth / 2.0
        let y = calculateGraphY(forDistance: distancesByDays[index].first!.value, whereMaximumIs: maximumDistance)
        
        let height = self.bounds.height - Constants.Graph.graphBottomMargin - y
        
        let flashLayer = CALayer()
        flashLayer.frame = CGRect(x: x, y: y, width: Constants.FlashAnimation.flashingSelectionWidth, height: height)
        flashLayer.opacity = 0.0
        flashLayer.backgroundColor = UIColor.white.cgColor
        
        self.layer.addSublayer(flashLayer)
        
        let flashAnimation = CABasicAnimation(keyPath: Constants.FlashAnimation.property)
        flashAnimation.fromValue = 0.0
        flashAnimation.toValue = Constants.FlashAnimation.desiredOpacity
        flashAnimation.duration = Constants.FlashAnimation.duration
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
            backgroundLinesPath.lineWidth = Constants.Graph.backgroundLineWidth
            
            let legendValues = [maximumDistance, maximumDistance / 2, 0]

            for value in legendValues {
                let yPosition = calculateGraphY(forDistance: value, whereMaximumIs: maximumDistance)
                
                let font = Constants.Graph.legendValuesFont
                let attributes = [NSAttributedString.Key.font: font,
                                  NSAttributedString.Key.foregroundColor: graphColor]
                let valueString = "\(DistanceToStringCoverter.stringDistance(fromDistance: value))" as NSString
                valueString.draw(at: CGPoint(x: self.bounds.width - Constants.Graph.graphRightMargin + 10,
                                             y: yPosition - valueString.size(withAttributes: attributes).height / 2), withAttributes: attributes)
                
                backgroundLinesPath.move(to: CGPoint(x: Constants.Graph.leftMargin, y: yPosition))
                backgroundLinesPath.addLine(to: CGPoint(x: self.bounds.width - Constants.Graph.rightMargin, y: yPosition))
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
        let font = Constants.Graph.weekdaysFont
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: graphColor]
        
        let calendar = Calendar.current        
        let weekdays: [NSString] = distancesByDays.map { calendar.shortWeekdaySymbols[$0.keys.first!] as NSString }
        for (index, weekday) in weekdays.enumerated() {
            weekday.draw(at: CGPoint(x: calculateGraphX(forDayIndex: index) - weekday.size(withAttributes: attributes).width / 2,
                                     y: self.bounds.height - Constants.Graph.graphBottomMargin + 5), withAttributes: attributes)
        }
    }
    
    private func calculateGraphX(forDayIndex index: Int) -> CGFloat {
        let availableWidth = self.bounds.width - Constants.Graph.graphLeftMargin - Constants.Graph.graphRightMargin
        let widthPerWeekday = availableWidth / CGFloat(Constants.Graph.totalWeekdaysPresentable - 1)
        return widthPerWeekday * CGFloat(index) + Constants.Graph.graphLeftMargin
    }
    
    private func calculateGraphY(forDistance distance: Double, whereMaximumIs maximum: Double) -> CGFloat {
        let availableHeight = self.bounds.height - Constants.Graph.graphBottomMargin - Constants.Graph.topMargin
        
        guard maximum > 0 else {
            return self.bounds.height - Constants.Graph.graphBottomMargin
        }
        
        let y = CGFloat(distance / maximum) * availableHeight + Constants.Graph.graphBottomMargin
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
