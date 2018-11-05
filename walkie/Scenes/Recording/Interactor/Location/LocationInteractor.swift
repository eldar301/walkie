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
    func didStartUpdateLocation(atLatitude: Double?, longitude: Double?)
    func didStopUpdateLocation()
    func update(withNewLatitude: Double, longitude: Double, distance: Double, accuracy: Double)
    func locationAccessNotGranted()
}

protocol LocationInteractor: class {
    
    var delegate: LocationInteractorDelegate? { get set }
    
    func startUpdate()
    func stopUpdate()
}

class LocationInteractorDefault: NSObject, LocationInteractor {
    
    weak var delegate: LocationInteractorDelegate?
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        return locationManager
    }()
    
    private var previousLocaition: CLLocation?
    
    func startUpdate() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            delegate?.locationAccessNotGranted()
            return
            
        default:
            break
        }
        
        locationManager.startUpdatingLocation()
        
        let coordinate = locationManager.location?.coordinate
            
        delegate?.didStartUpdateLocation(atLatitude: coordinate?.latitude, longitude: coordinate?.longitude)
    }
    
    func stopUpdate() {
        locationManager.stopUpdatingLocation()
        delegate?.didStopUpdateLocation()
    }
    
}

extension LocationInteractorDefault: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            return
        }
        
        var distanceDifference = 0.0
        if let previousLocation = self.previousLocaition {
            distanceDifference = previousLocation.distance(from: currentLocation)
        }

        delegate?.update(withNewLatitude: currentLocation.coordinate.latitude,
                         longitude: currentLocation.coordinate.longitude,
                         distance: distanceDifference,
                         accuracy: currentLocation.horizontalAccuracy)
        
        previousLocaition = currentLocation
    }
    
}
