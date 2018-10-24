//
//  LocationInteractor.swift
//  walkie
//
//  Created by Eldar Goloviznin on 05/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationInteractorDelegate: class {
    func locationProviderDidStartUpdate()
    func locationProviderDidStopUpdate()
    func update(withNewLatitude: Double, longitude: Double, distanceDifference: Double)
}

protocol LocationInteractor: class {
    var delegate: LocationInteractorDelegate? { get set }
    
    func startUpdate()
    func stopUpdate()
}

class LocationInteractorDefault: NSObject, LocationInteractor {
    
    weak var delegate: LocationInteractorDelegate?
    
    private var previousLocation: CLLocation?
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
//        locationManager.allowsBackgroundLocationUpdates = true
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
        delegate?.locationProviderDidStartUpdate()
    }
    
    func stopUpdate() {
        locationManager.stopUpdatingLocation()
        delegate?.locationProviderDidStopUpdate()
    }
    
}

extension LocationInteractorDefault: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            return
        }
        
        let distanceDifference = previousLocation?.distance(from: currentLocation) ?? 0
        
        print(currentLocation.horizontalAccuracy)
        
//        guard distanceDifference >= 0.5 * currentLocation.horizontalAccuracy else {
//            return
//        }
        
        delegate?.update(withNewLatitude: currentLocation.coordinate.latitude,
                         longitude: currentLocation.coordinate.longitude,
                         distanceDifference: distanceDifference)
        
        previousLocation = currentLocation
    }
    
}
