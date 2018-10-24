//
//  Date+Strideable.swift
//  walkie
//
//  Created by Eldar Goloviznin on 16/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation

extension Date: Strideable {
    
    public func advanced(by days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    public func distance(to other: Date) -> Int {
        let calendar = Calendar.current
        let selfStartOfDay = calendar.startOfDay(for: self)
        let otherStartOfDay = calendar.startOfDay(for: other)
        
        return calendar.dateComponents([.day], from: selfStartOfDay, to: otherStartOfDay).day!
    }
    
}
