//
//  MapViewController.swift
//  walkie
//
//  Created by Eldar Goloviznin on 16/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var presenter: MapPresenter!
    
    private var minLatitudeCoordinate: Double?
    private var maxLatitudeCoordinate: Double?
    private var minLongitudeCoordinate: Double?
    private var maxLongitudeCoordinate: Double?
    
    private var polylinesDict: [Walk: MKPolyline] = [:]
    
    private var currentWalkPolyline: MKPolyline?
    
    private var cachedCurrentWalkCoordinates: [CLLocationCoordinate2D] = []

    private var lastTimeUserInteractedWithMap: Date? = nil

    private let routeColors: [UIColor] = [.red, .blue, .orange, .green]
    private var nextColorIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.layer.cornerRadius = closeButton.bounds.height / 2.0
        
        mapView.delegate = self

        presenter.view = self
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func addRoute(forWalk walk: Walk, isCurrentWalk: Bool) {
        if let polyline = polylinesDict.removeValue(forKey: walk) {
            mapView.removeOverlay(polyline)
        }
            
        let mappedCoordinates = walk.coordinates?.map { coordinate -> CLLocationCoordinate2D in
            let coordinate = coordinate as! Coordinate
            return CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        
        guard let coordinates = mappedCoordinates else {
            return
        }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        let boundingRect = polyline.boundingMapRect
        
        minLatitudeCoordinate = min(minLatitudeCoordinate ?? boundingRect.minX, boundingRect.minX)
        maxLatitudeCoordinate = max(maxLatitudeCoordinate ?? boundingRect.maxX, boundingRect.maxX)
        minLongitudeCoordinate = min(minLongitudeCoordinate ?? boundingRect.minY, boundingRect.minY)
        maxLongitudeCoordinate = max(maxLongitudeCoordinate ?? boundingRect.maxY, boundingRect.maxY)
        
        if isCurrentWalk {
            cachedCurrentWalkCoordinates = coordinates
            currentWalkPolyline = polyline
        }
        
        polylinesDict[walk] = polyline
        
        mapView.addOverlay(polyline)
    }
    
    private func editCurrentWalkRoute(forWalk walk: Walk, withNewCoordinate coordinate: Coordinate, snapToRoute: Bool) {
        if let polyline = polylinesDict.removeValue(forKey: walk) {
            mapView.removeOverlay(polyline)
        }
        
        cachedCurrentWalkCoordinates.append(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
        
        let polyline = MKPolyline(coordinates: cachedCurrentWalkCoordinates, count: cachedCurrentWalkCoordinates.count)
        
        currentWalkPolyline = polyline
        
        polylinesDict[walk] = polyline
        
        mapView.addOverlay(polyline)
        
        if snapToRoute {
            mapView.setVisibleMapRect(polyline.boundingMapRect, animated: true)
        }
    }
    
}

extension MapViewController: MapView {
    
    func update(withWalks walks: [Walk]) {
        polylinesDict.removeAll()
        
        for walk in walks {
            addRoute(forWalk: walk, isCurrentWalk: false)
        }
        
        let snapMapRect = MKMapRect(x: minLatitudeCoordinate!,
                                    y: minLongitudeCoordinate!,
                                    width: maxLatitudeCoordinate! - minLatitudeCoordinate!,
                                    height: maxLongitudeCoordinate! - minLongitudeCoordinate!)
        
        mapView.setVisibleMapRect(snapMapRect, animated: true)
    }
    
    func update(currentWalk: Walk, withNewCoordinate coordinate: Coordinate) {
        mapView.showsUserLocation = true
        
        if cachedCurrentWalkCoordinates.isEmpty {
            addRoute(forWalk: currentWalk, isCurrentWalk: true)
        } else {
            var snapToRoute: Bool
            
            if let lastInteractDate = lastTimeUserInteractedWithMap {
                snapToRoute = lastInteractDate.timeIntervalSinceNow < -3
            } else {
                snapToRoute = true
            }
            
            editCurrentWalkRoute(forWalk: currentWalk, withNewCoordinate: coordinate, snapToRoute: snapToRoute)
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        if polyline === currentWalkPolyline {
            renderer.strokeColor = .black
        } else {
            renderer.strokeColor = routeColors[nextColorIndex]
            nextColorIndex = (nextColorIndex + 1) % routeColors.count
        }
        renderer.lineWidth = 2.0
        return renderer
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        lastTimeUserInteractedWithMap = Date()
    }
    
}
