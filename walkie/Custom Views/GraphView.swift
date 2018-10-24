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
}

class GraphView: RoundedView {
    
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
    
    var distancesByDays: [[Date: Double]] = []
    
    func update(withDistancesByDays distancesByDays: [[Date: Double]]) {
        self.distancesByDays = distancesByDays
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if let maximumDistance = distancesByDays.max(by: { $0.first!.value < $1.first!.value })?.first?.value, maximumDistance > 0 {
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
        let font = UIFont(name: "AvenirNext-Regular", size: 15)!
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: graphColor]
        
        let calendar = Calendar.current
        
        let weekdays: [NSString] = distancesByDays.map { calendar.veryShortWeekdaySymbols[calendar.component(.weekday, from: $0.keys.first!) - 1] as NSString }
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
        let y = CGFloat(distance / maximum) * availableHeight + Constants.graphBottomMargin
        return self.bounds.height - y
    }
    
}
