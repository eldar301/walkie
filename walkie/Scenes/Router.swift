//
//  Router.swift
//  walkie
//
//  Created by Eldar Goloviznin on 16/10/2018.
//  Copyright © 2018 Eldar Goloviznin. All rights reserved.
//

import Foundation
import UIKit

class Router {
    
    private weak var currentViewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.currentViewController = viewController
    }
    
    func setupRootScene() {
        guard let recordingVC = currentViewController as? RecordingViewController else {
            fatalError("Root scene should be initialized with RecordingViewController")
        }
        
        let locationInteractor = LocationInteractorDefault()
        let movementInteractor = MovementInteractorDefault()
        let walksInteractor = WalksInteractorDefault()
        
        let recordingPresenter = RecordingPresenterDefault(router: self,
                                                           locationInteractor: locationInteractor,
                                                           movementInteractor: movementInteractor,
                                                           walksInteractor: walksInteractor)
        
        recordingVC.presenter = recordingPresenter
    }
    
    func showMapScene(input: MapPresenterInput, autoupdates: Bool) {
        var presenter: MapPresenter?
        if autoupdates {
            presenter = MapPresenterDynamic(input: input)
        } else {
            presenter = MapPresenterStatic(input: input)
        }
        
        guard let mapPresenter = presenter else {
            return
        }
        
        let mapVC = UIStoryboard(name: "Map", bundle: nil).instantiateInitialViewController() as! MapViewController
        mapVC.presenter = mapPresenter
        
        present(viewController: mapVC)
    }
    
    private func present(viewController: UIViewController) {
        currentViewController?.present(viewController, animated: true)
    }
    
}
