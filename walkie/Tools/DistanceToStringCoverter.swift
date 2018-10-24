//
//  DistanceToStringCoverter.swift
//  walkie
//
//  Created by Eldar Goloviznin on 16/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation

class DistanceToStringCoverter {
    
    static func stringDistance(fromDistance distance: Double) -> String {
        switch distance {
        case 0..<100:
            return "\(String(format: "%.1f", distance)) m"
        case 100..<1000:
            return "\(String(format: "%.2f", distance / 1000)) km"
        default:
            return "\(String(format: "%.1f", distance / 1000)) km"
        }
    }
    
}
