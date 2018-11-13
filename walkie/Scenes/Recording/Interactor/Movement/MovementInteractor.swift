//
//  MovementInteractor.swift
//  walkie
//
//  Created by Eldar Goloviznin on 25/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation
import CoreMotion

protocol MovementInteractorDelegate: class {
    func update(withLastWeekStatistics: [[Date: Double]])
    func liveUpdate(distance: Double)
    func motionAccessNotGranted()
}

protocol MovementInteractor: class {
    
    var delegate: MovementInteractorDelegate? { get set }
    
    func fetchLastWeekStatistics()
    func startUpdate()
    func stopUpdate()
}

class MovementInteractorDefault: MovementInteractor {
    
    weak var delegate: MovementInteractorDelegate?
    
    private let pedometer = CMPedometer()
    
    private let weekdaysCount = 7
    
    func fetchLastWeekStatistics() {
        let currentDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        
        let group = DispatchGroup()
        
        var lastWeekStatistics: [[Date: Double]] = []
        for day in (0 ... weekdaysCount - 1).reversed() {
            var fetchingDateComponents = currentDateComponents
            fetchingDateComponents.day! -= day
            
            group.enter()
            fetchStatistics(forDateComponents: fetchingDateComponents, completion: { date, distance in
                lastWeekStatistics.append([date: distance])
                group.leave()
            })
        }
        
        group.notify(queue: .main) { [weak self] in
            if CMPedometer.authorizationStatus() != .authorized {
                self?.delegate?.motionAccessNotGranted()
            }
            
            self?.delegate?.update(withLastWeekStatistics: lastWeekStatistics)
        }
    }
    
    func startUpdate() {
        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let distance = data?.distance?.doubleValue else {
                return
            }
            
            DispatchQueue.main.async {
                self?.delegate?.liveUpdate(distance: distance)
            }
        }
    }
    
    func stopUpdate() {
        pedometer.stopUpdates()
    }
    
    private func fetchStatistics(forDateComponents dateComponents: DateComponents, completion: @escaping (Date, Double) -> ()) {
        let calendar = Calendar.current
        
        let fromDate = calendar.date(from: dateComponents)!
        let toDate = calendar.date(byAdding: .day, value: 1, to: fromDate)!
        
        pedometer.queryPedometerData(from: fromDate, to: toDate) { data, error in
            completion(fromDate, data?.distance?.doubleValue ?? 0)
        }
    }

    deinit {
        pedometer.stopUpdates()
    }
    
}
