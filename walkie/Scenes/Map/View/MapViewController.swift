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
    
    @IBOutlet weak var mapView: MKMapView!
    
    var presenter: MapPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.view = self
    }

}

extension MapViewController: MapView {
    
    func update(withWalks: [Walk]) {
        
    }
    
}
