//
//  LocationProvider.swift
//  walkie
//
//  Created by Eldar Goloviznin on 05/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationProviderDelegate: class {
    func update(withNewCoordinate: Coordinate, totalDistance: Double)
}

protocol LocationProvider {
    var delegate: LocationProviderDelegate? { get set }
    
    func startUpdate()
    func stopUpdate()
}

class LocationProviderDefault: NSObject, LocationProvider {
    
    weak var delegate: LocationProviderDelegate?
    
    private var previousLocation: CLLocation?
    
    private var totalDistance: Double = 0
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = self
        return locationManager
    }()
    
    func startUpdate() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            // FIXME: handle restricted status
            fatalError("FIXME: handle restricted status")
            
        default:
            break
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdate() {
        locationManager.stopUpdatingLocation()
    }
    
}

extension LocationProviderDefault: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            return
        }
        
        let locationDistanceDifference: Double = previousLocation?.distance(from: currentLocation) ?? 0
        
        totalDistance += locationDistanceDifference
        
        let currentCoordinate = Coordinate(latitude: currentLocation.coordinate.latitude,
                                           longitude: currentLocation.coordinate.longitude)
        
        delegate?.update(withNewCoordinate: currentCoordinate, totalDistance: totalDistance)
        
        previousLocation = currentLocation
    }
    
}
